module Funnels
  class FunnelEvent < ActiveRecord::Base
    belongs_to :user, optional: true

    validates :label,      presence: true
    validates :ip_address, presence: true
    validates :event_key,
      presence: true,
      format: { with: /^\w+$/, message: "only letters, numbers, and underscores" }
  end
end
