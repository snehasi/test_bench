module AppHelpers
  def hello
    raw("HELLO")
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def nav_link(label, path)
    """
    <li class='nav-item'>
      <a class='nav-link' href='#{path}'>#{label}</a>
    </li>
    """
  end

  def current_user
    @current_user ||= User.find_by_email(session[:usermail])
  end

  def logged_in?
    current_user
  end
end
