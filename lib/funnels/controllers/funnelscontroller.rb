class FunnelsController < ActionController
  def index
  end

  def show
  end

  def track
    event_key, label = event_params.values_at :event_key, :label
    funnel_event event_key, label,
      user_id:    current_user.id,
      ip_address: request.remote_ip,
      referrer:   request.referrer
  end

  private

  def event_params
    # ip_address taken directly from the request
    params.require(:event).permit(:event_key, :user_id, :label)
  end

  def current_user
    defined?(super) ? super : User.find(session[:user_id])
  end
end
