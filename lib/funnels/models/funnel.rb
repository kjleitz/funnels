module Funnels
  class Funnel < ActiveRecord::Base
    serialize :steps, Array

    validate  :steps_must_be_correct_structure
    validates :name,        presence: true, uniqueness: true
    validates :description, presence: true
    validates :tracked_by,  inclusion: [:user_id, :ip_address]

    before_validation :set_default_name

    def name(funnel_name)
      self.name = funnel_name
    end

    def description(funnel_desc)
      self.description = funnel_desc
    end

    def track_by(trackable)
      self.tracked_by = {
        user:       :user_id,
        user_id:    :user_id,
        ip:         :ip_address,
        ip_address: :ip_address
      }[trackable]
    end

    def starts_with(event_key)
      raise "This funnel already starts with an event!" if started?
      steps.unshift({ event_key: event_key, required: true })
      started!
    end

    def includes(event_key, required: false)
      at_index = ended? ? -2 : -1
      steps.insert(at_index, { event_key: event_key, required: required })
    end

    def ends_with(event_key)
      raise "This funnel already ends with an event!" if ended?
      steps << { event_key: event_key, required: true }
      ended!
    end

    def event_keys
      steps.map { |step| step[:event_key] }
    end
    
    def required_event_keys
      steps.select { |step| step[:required] }.map { |step| step[:event_key] }
    end
    
    def user_ids
      @user_ids ||= FunnelEvent.where(event_key: required_event_keys.first).pluck :user_id
    end

    # valid events consist of those whose users completed all preceding required events
    def valid_events_by_step
      @valid_events_by_step ||= begin
        user_ids_from_last_required_event = user_ids
        # IIRC, non-MRI implementations of Ruby may map over a hash in a different key order
        # than the one it was instantiated with. The normal interpreter should do it in the same
        # order just about always, or at least enough to be practical for this purpose
        all_events_by_step.map do |step_event_key, step_events|
          event_is_required = required_event_keys.include? step_event_key
          valid_events = step_events.where user_id: user_ids_from_last_required_event
          user_ids_from_last_required_event = valid_events.pluck(:user_id) if event_is_required
          [step_event_key, valid_events]
        end.to_h
      end
    end

    def valid_event_ids_by_step
      @valid_event_ids_by_step ||= valid_events_by_step.map do |step_event_key, step_events|
        [step_event_key, step_events.ids]
      end.to_h
    end

    def valid_event_ids
      valid_event_ids_by_step.values.flatten
    end

    def valid_events
      @valid_events ||= FunnelEvent.where id: valid_event_ids
    end


    private

    def set_default_name
      return unless name.blank? && description.present?
      words_and_spaces  = self.description.gsub /[^\w ]/, ''
      underscore_spaces = words_and_spaces.gsub / +/, '_'
      symbolized_desc   = underscore_spaces.downcase.to_sym
      self.name = symbolized_desc
    end

    def steps_must_be_correct_structure
      steps.all? do |step|
        errors.add :steps, "must be hashes" unless step.is_a? Hash
        errors.add :steps, "must have keys" unless step[:event_key].present?
        errors.add :steps, "must set :required" if step[:required].blank?
      end
    end

    def started!
      self.started = true
    end

    def ended!
      self.ended = true
    end

    def all_events
      @all_events ||= FunnelEvent.where event_key: event_keys, user_id: user_ids
    end

    def all_events_by_step
      event_keys.reduce {} do |memo, step_event_key|
        memo.merge({ step_event_key => all_events.where event_key: step_event_key })
      end
    end

    def required_events
      @required_events ||= FunnelEvent.where event_key: required_event_keys, user_id: user_ids
    end
  end
end
