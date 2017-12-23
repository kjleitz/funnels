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

    alias_method :tracked_by, :track_by

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

    def started!
      self.started = true
    end

    def ended!
      self.ended = true
    end

    def events
      @events ||= begin
        event_keys     = steps.map { |step| step[:event_key] }
        required_keys  = steps.select { |step| step[:required] }.map { |step| step[:event_key] }
        funnel_events  = FunnelEvent.where event_key: event_keys
        user_ids       = funnel_events.pluck :user_id
        valid_user_ids = user_ids.select do |uid|
          user_events = funnel_events.where user_id: uid
          event_keys.map { |event_key|  }
          # unfinished!
        end
      end
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
  end
end
