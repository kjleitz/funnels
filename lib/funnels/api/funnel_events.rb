module Funnels
  module FunnelEvents
    extend ActiveSupport::Concerns

    included do
      def funnel_event(event_key = nil, event_label = nil, **opts)
        options    = opts.clone
        event_key  = event_key   || options.delete(:event_key)
        label      = event_label || options.delete(:label) || event_key.to_s.capitalize.tr '_', ' '
        user_id    = options.delete(:user_id)    || current_user.id
        ip_address = options.delete(:ip_address) || request.remote_ip
        referrer   = options.delete(:referrer)   || request.referrer

        attrs = {
          event_key:  event_key,
          label:      label,
          user_id:    user_id,
          ip_address: ip_address,
          referrer:   referrer
        }.merge(options)

        Funnels::FunnelEvent.create **attrs
      end
    end
  end
end
