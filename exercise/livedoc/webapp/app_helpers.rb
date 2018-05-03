require 'time'

module AppHelpers
  def hello
    raw("HELLO")
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  # -----

  def contract_id_link(contract)
    "<a href='/contracts/#{contract.uuid}'>#{contract.xid}</a>"
  end

  def contract_mature_date(contract)
    color = BugmTime.now > contract.maturation ? "red" : "green"
    date = contract.maturation.strftime("%m-%d %H:%M %Z")
    "<span style='color: #{color};'>#{date}</span>"
  end

  def contract_status(contract)
    case contract.status
    when "open"     then "<i class='fa fa-unlock'></i> open"
    when "matured"  then "<i class='fa fa-lock'></i> matured"
    when "resolved" then "<i class='fa fa-check'></i> resolved"
    else "UNKNOWN_CONTRACT_STATE"
    end
  end

  def contract_earnings(user, contract)
    return "NA" unless contract.resolved?
    contract.value_for(user)
  end

  # -----

  def repo_link
    url = TS.repo_url
    "<a href='http://#{url}' target='_blank'>Document Repo</a>"
  end

  def tracker_link(issue = nil, label = nil)
    url = case TS.tracker_type.to_sym
      when :yaml   then yaml_tracker_url(issue)
      when :github then github_tracker_url(issue)
    end
    lbl = label || url
    "<a href='#{url}' target='_blank'>#{lbl}</a>"
  end

  def yaml_tracker_url(issue)
    base = "http://#{TS.webapp_url}/ytrack"
    issue ? "#{base}/#{issue.exid}" : base
  end

  def github_tracker_url(issue)
    base = "http://github.com/#{TS.tracker_name}/issues"
    issue ? "#{base}/#{issue.exid}" : base
  end

  def current_page(path)
    request.path_info == path
  end

  def ytrack_nav_menu
    iora = Iora.new(TS.tracker_type, TS.tracker_name)
    iora.issues.map do |el|
      label = el["stm_title"]
      exid  = el["exid"]
      ytrack_nav(label, "/ytrack/#{exid}")
    end.join
  end

  def ytrack_nav(label, path)
    href = "<a href='#{path}'>#{label}</a>"
    link = current_page(path) ? label :  href
    """
    <hr style='margin:0; padding:0;'/>
    #{link}
    """
  end

  def help_nav(label, path)
    href = "<a href='#{path}'>#{label}</a>"
    link = current_page(path) ? label :  href
    """
    <hr/>
    #{link}
    """
  end

  def base_link(label, path, jump = nil)
    tgt = jump ? "target=_blank" : ""
    href = "<a href='#{path}' #{tgt}>#{label}</a>"
    current_page(path) ? label :  href
  end

  def nav_btn(label, path)
    active = current_page(path) ? 'active' : ''
    """
    <li class='nav-item #{active}'>
      <a class='nav-link btn-like' role='button' href='#{path}'>#{label}</a>
    </li>
    """
  end

  def nav_link(label, path)
    active = current_page(path) ? 'active' : ''
    """
    <li class='nav-item #{active}'>
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

  # ----- auth / consent -----

  def current_user
    @current_user ||= User.find_by_email(session[:usermail])
  end

  def consented?
    session[:consent]
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

  def valid_consent(_user)
    # look up valid consent
    false
  end

  def protected!
    authenticated!
    consented!
  end

  def authenticated!
    return if logged_in?
    flash[:danger]     = "Please log in"
    session[:tgt_path] = request.path_info
    redirect "/login"
  end

  def consented!
    return if consented?
    redirect "/consent_form"
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

  def start_date
    xformat TS.start_date
  end

  def finish_date
    xformat TS.finish_date
  end

  def xformat(time)
    time.strftime("%B %d")
  end

  def participant_list(args = {})
    puts args.inspect
    TS.participants.sort.map do |email|
      args[:obfuscated] ? obfuscate(email) : email
    end.join(", ")
  end

  def obfuscate(email)
    name, domain = email.split('@')
    comp, ext = domain.split(".")
    "<code>#{name}@#{comp.gsub(/./, '*')}.#{ext}</code>"
  end
end
