require 'time'

module AppHelpers

  include ActionView::Helpers::DateHelper

  # ----- scale -----


  # ----- positions -----

  def position_count(user)
    return 0 unless user
    sellable_positions(user).count + buyable_positions.count
  end

  def sellable_positions(user)
    user.positions.unresolved.fixed.unoffered
  end

  def buyable_positions
    Offer::Sell::Fixed.open
  end

  # ----- date formatting -----
  def dvis(time = BugmTime.now)
    time.strftime("%b %d")
  end

  def dstr(time = BugmTime.now)
    time.strftime("%Y-%m-%d")
  end

  # ----- investment -----

  def invested_tokens(user)
    user.offers.pluck(:value).sum
  end

  def underactivity_penalty(user)
    0
  end

  # ----- events -----

  def clean_cmd(event)
    event.cmd_type.gsub("Cmd::", "")
  end

  def clean_type(event)
    event.event_type.gsub("Event::", "")
  end

  def clean_payload(event)
    ex = %w(uuid encrypted_password exid stm_body stm_tracker_uuid html_url)
    event.payload.except(*ex)
  end

  def user_links(event)
    event.user_uuids.map do |x|
      y = x || ""
      "<a href='/events_user/#{y}'>#{y[0..5]}</a>"
    end.join(", ")
  end

  # ----- funding hold -----

  def account_lbl(user)
    "#{user_name(user)} / balance: #{user.token_available}"
  end

  # ----- time -----

  def timezone
    BugmTime.now.strftime("%Z")
  end

  def timewords(alt_time = Time.now + 1.hour)
    time_ago_in_words(alt_time)
  end

  def eod_words
    distance_of_time_in_words(BugmTime.now, BugmTime.end_of_day)
  end

  def contract_maturation_words(contract)
    str = distance_of_time_in_words(BugmTime.now, contract.maturation)
    BugmTime.now > contract.maturation ? "#{str} ago" : "in #{str}"
  end

  def eod_iso
    BugmTime.end_of_day.strftime("%Y%m%dT%H%M%S")
  end

  # ----- info icon -----

  def i_circle
    "<i class='fa fa-info-circle'></i>"
  end

  def ic_link(tgt)
    "<a href='#{tgt}'>#{i_circle}</a>"
  end

  # ----- issues -----

  def issue_offerable?(user, issue)
    issue.offers.where('expiration > ?', BugmTime.now).pluck(:user_uuid).include?(user.uuid)
  end

  def issue_id_link(issue)
    "<a href='/issues/#{issue.uuid}'>#{issue.xid}</a>"
  end

  def issue_status(issue)
    issue.stm_status
  end

  def issue_value(issue)
    issue.offers.open.pluck(:value).sum
  end

  def issue_color(issue)
    issue_status(issue) == "open" ? "#4c1" : "#721"
  end

  # ----- offers -----

  def offer_id_link(offer)
    "<a href='/offers/#{offer.uuid}'>#{offer.xid}</a>"
  end

  def offer_status(offer)
    offer.status
  end

  def offer_value(offer)
    offer.value
  end

  def offer_color(offer)
    offer.status == "open" ? "#4c1" : "#721"
  end

  def offer_maturation_date(offer)
    return "TBD" if offer.maturation.nil?
    color = BugmTime.now > offer.maturation ? "red" : "green"
    date = offer.maturation.strftime("%m-%d %H:%M")
    date_iso = offer.maturation.strftime("%Y%m%dT%H%M%S")
    "<a target='_blank' style='color: #{color}' href='https://www.timeanddate.com/worldclock/fixedtime.html?iso=#{date_iso}&p1=217'>#{date}</a>"
  end

  def offer_expiration_date(offer)
    return "TBD" if offer.expiration.nil?
    offer.expiration.strftime("%m-%d %H:%M %Z")
  end

  def offer_status_link(offer)
    case offer.status
    when 'crossed'
      "<a href='/contracts/#{offer.position.contract.uuid}'>crossed</a>"
    else
      offer.status
    end
  end

  def offer_sell_link(offer)
    counter = offer.position.counterpositions.first
    ixid = offer.issue.xid.capitalize
    oval = offer.value.to_i
    "
    <a href='#' class='ttip' data-oval='#{oval}' data-ixid='#{ixid}' data-toggle='tooltip' id='#{counter.uuid}'>
    #{user_name(offer.position.counterusers.first)}
    </a>
    "
  end

  def sellable_offer(user, offer)
    return false unless user == offer.position.counterusers.first
    poz  =  offer.position.counterpositions.first
    user.positions.unresolved.fixed.unoffered.include?(poz)
  end

  def offer_funder_link(user, offer, action = "offer_accept")
    return user_name(offer.user) if offer.is_unfixed?
    case offer.status
    when 'crossed'
      if false # sellable_offer(current_user, offer)
        offer_sell_link(offer)
      else
        user = offer.position.counterusers.first
        user_name(user)
      end
    when 'expired'
      'EXPIRED'
    when 'open'
      if offer.user.uuid == user.uuid
        "My Offer"
      else
        "<a class='btn btn-primary btn-sm bxs' href='/#{action}/#{offer.uuid}'>ACCEPT OFFER</a>"
      end
    else
      "TBD"
    end
  end

  def offer_worker_link(user, offer, action = "offer_accept")
    return user_name(offer.user) if offer.is_fixed?
    case offer.status
    when 'crossed'
      if false # sellable_offer(current_user, offer)
        offer_sell_link(offer)
      else
        user = offer.position.counterusers.first
        user_name(user)
      end
    when 'expired'
      'EXPIRED'
    when 'open'
      if offer.user.uuid == user.uuid
        "My Offer"
      # elsif offer.issue.offers.where('expiration > ?', BugmTime.now).where(type: "Offer::Buy::Unfixed").pluck(:user_uuid).include?(user.uuid)
      #   "You funded this issue"
      else
        "<a class='btn btn-primary btn-sm bxs' href='/#{action}/#{offer.uuid}'>ACCEPT OFFER</a>"
      end
    end
  end

  def offer_fund_link(user, issue)
    return "Low Balance - Can't Fund Offers" if user.token_available < 10
    "<a class='btn btn-primary btn-sm' href='/offer_fund/#{issue.uuid}'>FUND A NEW OFFER (cost: 10 tokens)</a>"
  end

  def offer_fund_message(user, issue)
    return "" if user.token_available < 10
    return "" if issue_offerable?(user, issue)
    "<i>Trader and worker both pay 10 tokens. Winner receives 20 tokens on maturation.</i>"
  end

  def offer_awardee(offer)
    return "was not accepted"     if offer.status == 'expired'
    return "needs to be accepted" if offer.status != 'crossed'
    return "waiting for maturation" if offer.position.contract.status != 'resolved'
    user = Position.where("amendment_uuid = '#{offer.position.amendment.uuid}' AND side = '#{offer.position.contract.awardee}'").first&.user
    if user&.uuid == offer.user&.uuid then
      user_type = "trader"
    else
      user_type = "worker"
    end
    "#{user_type} <b>#{user_name(user)}</b> received #{offer.volume.to_i} tokens"
  end

  # ----- contracts -----

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
    return "waiting for maturation" unless contract.resolved?
    contract.value_for(user)
  end

  def fixed_username(contract)
    user_name(contract.positions.fixed.first.user)
  end

  def unfixed_username(contract)
    user_name(contract.positions.unfixed.first.user)
  end

  def escrow_awardee(escrow)
    return "NA" if escrow.contract.status != 'resolved'
    user = Position.where("amendment_uuid = '#{escrow.amendment.uuid}' AND side = '#{escrow.contract.awardee}'").first.user
    # user = escrow.position.where(side: contract.awardee).first.user
    user_name(user)
  end

  # ----- links -----

  def repo_link
    url = TS.repo_url
    "<a href='http://#{url}' target='_blank'>Document Repo</a>"
  end

  def tracker_btn(issue = nil, label = nil)
    type = TS.tracker_type.to_s
    url = case type
      when "yaml"   then yaml_tracker_url(issue)
      when "github" then github_tracker_url(issue)
    end
    lbl = label || (type.capitalize + " ##{issue.sequence}")
    kls = "btn.btn-sm.btn-primary"
    "<a class='#{kls}' role='button' href='#{url}' target='_blank'>#{lbl}</a>"
  end

  def tracker_link(issue = nil, label = nil)
    type = TS.tracker_type
    url = case type&.to_sym
      when :yaml   then yaml_tracker_url(issue)
      when :github then github_tracker_url(issue)
      else "TBD"
    end
    lbl = label || url
    "<a href='#{url}' target='_blank'>#{lbl}</a>"
  end

  def github_tracker_url(issue)
    return "NA" unless issue
    base = "http://github.com/#{issue.tracker.name}/issues"
    issue ? "#{base}/#{issue.sequence}" : base
  end

  def current_page(path)
    request.path_info == path
  end

  # ----- ytrack -----

  def yaml_tracker_url(issue)
    base = "http://#{TS.webapp_url}/ytrack"
    issue ? "#{base}/#{issue.exid}" : base
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

  def ytrack_action_btn(issue)
    lbl = issue['stm_status'] == "open" ? "close" : "open"
    "<a href='/ytrack_#{lbl}/#{issue["exid"]}' class='btn btn-sm btn-primary'>click to #{lbl}</a>"
  end

  # -----

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

  def link_uc(label, path, opts = {})
    if current_page(path)
      return "" if opts[:hide] || opts["hide"]
      label
    else
      "<a href='#{path}'>#{label}</a>"
    end
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

  def user_name(user = current_user)
    if user
      user&.name || user&.uuid[0..5]
    else
      "TBD"
    end
  end

  def logged_in?
    current_user
  end

  def valid_consent(user)
    AccessLog.new(user&.email).has_consented?
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
    return "TBD" if time.nil?
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

  # ----- testing -----

  def hello
    raw("HELLO")
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

end
