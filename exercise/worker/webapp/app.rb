require_relative "./lib/web_util"
require_relative "./app_helpers"

require 'sinatra'
require 'sinatra/flash'
require 'sinatra/content_for'

set :bind, '0.0.0.0'
set :root, File.dirname(__FILE__)
enable :sessions

helpers AppHelpers

# ----- core app -----

get "/" do
  slim :home
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

# render a dynamic SVG for the offer
get '/badge/*' do |offer_uuid|
  content_type 'image/svg+xml'
  @offer = Offer.find_by_uuid(offer_uuid.split(".").first)
  erb :badge
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

# form a contract
get "/transact/:offer_uuid" do
  protected!
  user_uuid = current_user.uuid
  offer     = Offer.find_by_uuid(params['offer_uuid'])
  counter   = OfferCmd::CreateCounter.new(offer, user_uuid: user_uuid).project.offer
  contract  = ContractCmd::Cross.new(counter, :expand).project.contract
  flash[:success] = "You have formed a new contract"
  redirect "/contracts/#{contract.uuid}"
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
  slim :login
end

post "/login" do
  mail, pass = [params["usermail"], params["password"]]
  user = User.find_by_email(mail)
  valid_auth    = user && user.valid_password?(pass)
  valid_consent = valid_consent(user)
  case
  when valid_auth && valid_consent
    session[:usermail] = mail
    session[:consent]  = true
    flash[:success]    = "Logged in successfully"
    AccessLog.new(current_user&.email).logged_in
    path = session[:tgt_path]
    session[:tgt_path] = nil
    redirect path || "/"
  when ! valid_auth
    flash[:danger] = "Invalid username or password"
    redirect "/login"
  when ! valid_consent
    session[:usermail] = mail
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

# ----- misc / testing -----

get "/tbd" do
  slim :ztbd
end

get "/ztst" do
  slim :ztst
end
