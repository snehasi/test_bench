module AppHelpers
  def hello
    raw("HELLO")
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def iora_nav_menu
    iora = Iora.new(TS.repo_type, TS.repo_name)
    iora.issues.map do |el|
      label = el["stm_title"]
      exid  = el["exid"]
      iora_nav(label, "/iora/#{exid}")
    end.join
  end

  def iora_nav(label, path)
    """
    <hr style='margin:0; padding:0;'/>
    <a href='#{path}'>#{label}</a>
    """
  end

  def help_nav(label, path)
    """
    <hr/>
    <a href='#{path}'>#{label}</a>
    """
  end

  def nav_btn(label, path)
    """
    <li class='nav-item'>
      <a class='nav-link btn-like' role='button' href='#{path}'>#{label}</a>
    </li>
    """
  end

  def nav_link(label, path)
    """
    <li class='nav-item'>
      <a class='nav-link' href='#{path}'>#{label}</a>
    </li>
    """
  end

  def nav_text(label)
    """
    <li class='nav-item'>
      <span class='navbar=text'>#{label}</span>
    </li>
    """
  end

  def current_user
    @current_user ||= User.find_by_email(session[:usermail])
  end

  def user_mail
    current_user&.email
  end

  def user_name
    user_mail&.split("@")&.first
  end

  def logged_in?
    current_user
  end

  def protected!
    return if logged_in?
    flash[:danger]     = "Please log in"
    session[:tgt_path] = request.path_info
    redirect "/login"
  end

  # ----- offer helpers
  def issue_title(offer)
    offer.issue.stm_title
  end

  def issue_word(offer)
    issue_title(offer).split("_").first
  end

  def issue_type(offer)
    letter = issue_title(offer).split("_").last[0]
    case letter
      when "c" then "Comment"
      when "p" then "PR"
      else "NA"
    end
  end

  def issue_hint(offer)
    issue_title(offer)[-1]
  end
end
