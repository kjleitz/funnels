ActionController::Base.class_eval do
  include Funnels::FunnelEvents
end
