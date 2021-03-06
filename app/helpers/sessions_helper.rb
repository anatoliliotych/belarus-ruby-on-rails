module SessionsHelper

  def deny_access
    store_location
    redirect_to new_user_session_path
  end

  private

  def store_location(path = nil)
    session[:return_to] = path || request.fullpath
  end

  def get_stored_location
    stored_location = session[:return_to] || request.env['omniauth.origin']
    clear_stored_location
    (stored_location || root_path).to_s
  end

  def clear_stored_location
    session[:return_to] = nil
  end

end
