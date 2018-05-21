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

# ----- issues -----

# show one issue
get "/issues/:uuid" do
  protected!
  @issue = Issue.find_by_uuid(params['uuid'])
  slim :issue
end

# list all issues
get "/issues" do
  protected!
  @issues = Issue.open
  slim :issues
end

# render a dynamic SVG for the issues
get '/badge/*' do |issue_uuid|
  content_type 'image/svg+xml'
  cache_control :no_cache
  expires 0
  last_modified Time.now
  etag SecureRandom.hex(10)
  @issue = Issue.find_by_uuid(issue_uuid.split(".").first)
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
  counter   = OfferCmd::CreateCounter.new(offer, user_uuid: user_uuid).project.offer
  contract  = ContractCmd::Cross.new(counter, :expand).project.contract
  flash[:success] = "You have formed a new contract"
  redirect "/contracts/#{contract.uuid}"
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
  @navbar = :layout_nav_ytrack
  @exid   = params['exid']
  @issue  = Iora.new(TS.tracker_type, TS.tracker_name).issue(@exid)
  @page   = "issue"
  slim :ytrack
end

get "/ytrack" do
  @navbar = :layout_nav_ytrack
  @page   = "home"
  slim :ytrack
end

get "/ytrack_close/:exid" do
  @exid = params['exid']
  iora = Iora.new(TS.tracker_type, TS.tracker_name)
  issue = iora.issue(@exid)
  iora.close(issue["sequence"])
  flash[:success] = "Issue was closed"
  redirect "/ytrack/#{@exid}"
end

get "/ytrack_open/:exid" do
  @exid = params['exid']
  iora = Iora.new(TS.tracker_type, TS.tracker_name)
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
