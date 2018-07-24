require_relative "./lib/web_util"
require_relative "./lib/balance"
require_relative "./app_helpers"

require 'sinatra'
require 'sinatra/flash'
require 'sinatra/content_for'

require 'securerandom'

set :bind, '0.0.0.0'
set :root, File.dirname(__FILE__)
enable :sessions

helpers AppHelpers

# ----- filters -----
before do
  @start_clock = Time.now
end

after do
  if USE_INFLUX == true
    path = request.env["REQUEST_PATH"]
    meth = request.env["REQUEST_METHOD"]
    user = current_user&.email || "NA"
    time = Time.now - @start_clock
    args = {
      tags: {
        user: user,
        method: meth,
        path: path
      },
      values: {req_time: time},
      timestamp: BugmTime.now.to_i
    }
    InfluxViews.write_point "Request", args
  end
end

# ----- core app -----

get "/" do
  slim :home
end

# ----- events -----

get "/events" do
  @events = Event.all
  slim :events
end

get "/events/:event_uuid" do
  @event = Event.find_by_event_uuid(params['event_uuid'])
  slim :event
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
  @issue     = Issue.find_by_uuid(params['uuid'])
  @contracts = @issue.contracts
  @events    = Event.where("payload->>'exid' = ?", @issue.exid) || []
  @offers    = @issue.offers.open.without_branch_position
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

get "/sync_now" do
  protected!
  script = File.expand_path("../script/issue_sync", __dir__)
  job = fork {exec script}
  Process.detach(job)
  flash[:success] = "Issue sync has started - estimated finish in 60 seconds..."
  redirect "/issues"
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

get "/all_offers" do
  protected!
  @label  = "All Offers"
  @offers = Offer.all
  slim :offers
end

# cancel an offer
get "/offer_cancel/:offer_uuid" do
  offer = Offer.find_by_uuid(params['offer_uuid'])
  issue = offer.issue
  OfferCmd::Cancel.new(offer).project
  flash[:success] = "Offer was cancelled"
  redirect "/issues/#{issue.uuid}"
end

# create an offer
post "/offer_create/:issue_uuid" do
  protected!
  uuid  = params['issue_uuid']
  issue = Issue.find_by_uuid(uuid)
  opts = {
    aon:            params['side'] == 'unfixed' ? true : false ,
    price:          params['side'] == 'unfixed' ? 0.80 : 0.20  ,
    volume:         params['value'].to_i                       ,
    user_uuid:      current_user.uuid,
    maturation:     Time.parse(params['maturation']).change(hour: 23, min: 55),
    expiration:     Time.parse(params['expiration']).change(hour: 23, min: 50),
    poolable:       false,
    stm_issue_uuid: uuid
  }
  if issue
    type = params['side'] == 'unfixed' ? :offer_bu : :offer_bf
    result = FB.create(type, opts).project
    offer = result.offer
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
  @events = Event.for_user(current_user).order(:id)
  @rows   = Balance.new(@events).rows
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

# ----- coffeescript -----

get "/coffee/*.js" do
  filename = params[:splat].first
  coffee "coffee/#{filename}".to_sym
end

# ----- misc / testing -----

get "/tbd" do
  slim :ztbd
end

get "/ztst" do
  slim :ztst
end
