module Funnels
  class FunnelSerializer < ActiveModel::Serializer
    attributes \
      :name,
      :description,
      :tracked_by,
      :steps,
      :event_keys,
      :required_event_keys,
      :user_ids,
      :valid_event_ids_by_step,
      :valid_event_ids # maybe this one isn't necessary; it's easily calculated from `..._by_step`
  end
end
