require_relative "./lib/web_util"
require_relative "./app_helpers"

require 'sinatra'
require 'sinatra/flash'
require 'sinatra/content_for'

require 'securerandom'

set :bind, '0.0.0.0'
set :root, File.dirname(__FILE__)
enable :sessions

helpers AppHelpers

# ----- core app -----

get "/" do
  slim :home
end

# ----- wordquest -----

get "/wordquest/:hexid" do
  protected!
  @hexid  = params["hexid"].upcase
  @issue  = Issue.by_hexid(@hexid).first
  @cwrd   = CodeWord.new
  @issues = @cwrd.issues_for_user(current_user.uuid)
  @kwd    = @cwrd.codeword_for_user(@issue.sequence, current_user.uuid)
  slim :wordquest
end

post "/wordquest/:hexid" do
  protected!
  cwrd = CodeWord.new
  c1, c2 = [params['codeword1'].capitalize, params['codeword2'].capitalize]
  if solution = cwrd.solution_for(c1, c2)
    flash[:solution] = "The solution for: #{c1} + #{c2} = <b>#{solution}</b>"
  else
    flash[:danger] = "No solution was found for / #{c1} / #{c2} /"
  end
  redirect "/wordquest/#{params["hexid"]}"
end

get "/wordquest" do
  protected!
  @issues = CodeWord.new.issues_for_user(current_user.uuid)
  slim :wordquest
end

get "/wordkeys" do
  protected!
  @cwrd = CodeWord.new.issues
  slim :wordkeys
end

# ----- events -----

get "/events" do
  @events = Event.all
  slim :events
end

get "/events_user/:user_uuid" do
  user = User.find_by_uuid(params['user_uuid'])
  @title  = user.email
  @events = Event.for_user(user)
  slim :events
end

# ----- issues -----

# show one issue
get "/issues/:uuid" do
  protected!
  @issue = Issue.find_by_uuid(params['uuid'])
  @offers_bu = @issue.offers_bu.without_branch_position.select do |offer|
    next true if offer.is_not_crossed?
    offer.position.counterpositions.first.offers_sell.length == 0
  end
  @offers_sf = @issue.offers_sf.without_branch_position
  slim :issue
end

# show one issue
get "/issues_ex/:exid" do
  protected!
  issue = Issue.find_by_exid(params['exid'])
  redirect "/issues/#{issue.uuid}"
end

# list all issues
get "/issues" do
  protected!
  @issues = Issue.open
  slim :issues
end

# render a dynamic SVG for the issues
get '/badge_ex/*' do |issue_exid|
  content_type 'image/svg+xml'
  cache_control :no_cache
  expires 0
  last_modified Time.now
  etag SecureRandom.hex(10)
  @issue = Issue.find_by_exid(issue_exid.split(".").first)
  erb :badge
end

# ----- offers -----

# show one offer
get "/offers/:uuid" do
  protected!
  @offer = Offer.find_by_uuid(params['uuid'])
  slim :offer
end

# list all offers
get "/offers" do
  protected!
  @offers = Offer.open.with_issue.all
  slim :offers
end

# fund an offer
get "/offer_fund/:issue_uuid" do
  protected!
  uuid  = params['issue_uuid']
  issue = Issue.find_by_uuid(uuid)
  opts = {
    price:          0.50,
    volume:         20,
    user_uuid:      current_user.uuid,
    maturation:     BugmTime.end_of_day,
    expiration:     BugmTime.end_of_day,
    poolable:       false,
    stm_issue_uuid: uuid
  }
  if issue
    offer = FB.create(:offer_bu, opts).project.offer
    flash[:success] = "You have funded a new offer (#{offer.xid})"
  else
    flash[:danger] = "Something went wrong"
  end
  redirect "/issues/#{uuid}"
end

# accept offer and form a contract
get "/offer_accept/:offer_uuid" do
  protected!
  user_uuid = current_user.uuid
  uuid      = params['offer_uuid']
  offer     = Offer.find_by_uuid(uuid)
  counter   = OfferCmd::CreateCounter.new(offer, poolable: false, user_uuid: user_uuid).project.offer
  contract  = ContractCmd::Cross.new(counter, :expand, offer).project.contract
  flash[:success] = "You have formed a new contract"
  redirect "/issues/#{contract.issue.uuid}"
end

# ----- positions -----

get "/positions" do
  protected!
  @sellable = sellable_positions(current_user)
  @buyable  = buyable_positions
  slim :positions
end

post "/position_sell/:position_uuid" do
  protected!
  position = Position.find_by_uuid(params['position_uuid'])
  issue    = position.offer.issue
  value    = params['value'].to_i
  price    = (20 - value) / 20.0
  result   = OfferCmd::CreateSell.new(position, price: price)
  alt = result.project
  flash[:success] = "You have made an offer to sell your position"
  redirect "/issues/#{issue.uuid}"
end

get "/position_buy/:offer_uuid" do
  protected!
  user_uuid = current_user.uuid
  uuid      = params['offer_uuid']
  offer     = Offer.find_by_uuid(uuid)
  result    = OfferCmd::CreateCounter.new(offer, poolable: false, user_uuid: user_uuid)
  counter   = result.project.offer
  obj       = ContractCmd::Cross.new(counter, :transfer, offer)
  contract  = obj.project.contract
  flash[:success] = "You have formed a new contract"
  redirect "/issues/#{contract.issue.uuid}"
end

# ----- contracts -----

# show one contract
get "/contracts/:uuid" do
  protected!
  @contract = Contract.find_by_uuid(params['uuid'])
  slim :contract
end

# list my contracts
get "/contracts" do
  protected!
  @title     = "My Contracts"
  @contracts = current_user.contracts
  slim :contracts
end

# list all contracts
get "/contracts_all" do
  protected!
  @title     = "All Contracts"
  @contracts = Contract.all
  slim :contracts
end

# ----- user account -----

get "/account" do
  protected!
  @events = Event.for_user(current_user)
  slim :account
end

post "/set_username" do
  protected!
  user = current_user
  user.name = params["newName"]
  if user.save
    flash[:success] = "Your new username is '#{params["newName"]}'"
  else
    flash[:danger] = user.errors.messages.values.flatten.join(" ")
  end
  redirect "/account"
end

# ----- login/logout -----

get "/login" do
  if current_user
    flash[:danger] = "You are already logged in!"
    redirect back
  else
    slim :login
  end
end

post "/login" do
  mail, pass = [params["usermail"], params["password"]]
  user = User.find_by_email(mail) || User.find_by_name(mail)
  valid_auth    = user && user.valid_password?(pass)
  valid_consent = valid_consent(user)
  case
  when valid_auth && valid_consent
    session[:usermail] = user.email
    session[:consent]  = true
    flash[:success]    = "Logged in successfully"
    AccessLog.new(current_user&.email).logged_in
    path = session[:tgt_path]
    session[:tgt_path] = nil
    redirect path || "/"
  when ! user
    word = (/@/ =~ params["usermail"]) ? "Email Address" : "Username"
    flash[:danger] = "Unrecognized #{word} (#{params["usermail"]}) please try again or contact #{TS.leader_name}"
    redirect "/login"
  when ! valid_auth
    flash[:danger] = "Invalid password - please try again or contact #{TS.leader_name}"
    redirect "/login"
  when ! valid_consent
    session[:usermail] = mail
    AccessLog.new(current_user&.email).logged_in
    redirect "/consent_form"
  end
end

get "/logout" do
  session[:usermail] = nil
  session[:consent] = nil
  flash[:warning] = "Logged out"
  redirect "/"
end

# ----- consent -----

get "/consent_form" do
  authenticated!
  slim :consent
end

get "/consent_register" do
  authenticated!
  AccessLog.new(current_user&.email).consented
  session[:consent] = true
  path = session[:tgt_path]
  session[:tgt_path] = nil
  redirect path || "/"
end

# ----- help -----

get "/help/:page" do
  @page = params['page']
  slim :help
end

get "/help" do
  @page = "base"
  slim :help
end

# ----- ytrack issue tracker -----

get "/ytrack/:exid" do
  tracker_name = iora_tracker_name_for(TS.tracker_type, TS.tracker_name)
  @navbar = :layout_nav_ytrack
  @exid   = params['exid']
  @issue  = Iora.new(TS.tracker_type, tracker_name).issue(@exid)
  @page   = "issue"
  slim :ytrack
end

get "/ytrack" do
  @navbar = :layout_nav_ytrack
  @page   = "home"
  slim :ytrack
end

get "/ytrack_close/:exid" do
  tracker_name = iora_tracker_name_for(TS.tracker_type, TS.tracker_name)
  @exid = params['exid']
  iora = Iora.new(TS.tracker_type, tracker_name)
  issue = iora.issue(@exid)
  iora.close(issue["sequence"])
  flash[:success] = "Issue was closed"
  redirect "/ytrack/#{@exid}"
end

get "/ytrack_open/:exid" do
  tracker_name = iora_tracker_name_for(TS.tracker_type, TS.tracker_name)
  @exid = params['exid']
  iora = Iora.new(TS.tracker_type, tracker_name)
  issue = iora.issue(@exid)
  iora.open(issue["sequence"])
  flash[:success] = "Issue was opened"
  redirect "/ytrack/#{@exid}"
end

# ----- admin -----

get "/admin" do
  @users = User.all
  @contracts = Contract.open
  @offers = Offer.open
  slim :admin
end

get "/admin/sync" do
  script = File.expand_path("../script/issue_sync_all", __dir__)
  system script
  flash[:success] = "You have synced the issue tracker"
  redirect '/admin'
end

get "/admin/resolve" do
  script = File.expand_path("../script/contract_resolve", __dir__)
  system script
  flash[:success] = "You have resolved mature contracts"
  redirect '/admin'
end

# ----- misc / testing -----

get "/tbd" do
  slim :ztbd
end

get "/ztst" do
  slim :ztst
end
