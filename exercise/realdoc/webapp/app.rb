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
  slim :account
end

# ----- login/logout -----

get "/login" do
  slim :login
end

post "/login" do
  mail, pass = [params["usermail"], params["password"]]
  user = User.find_by_email(mail)
  if user && user.valid_password?(pass)
    session[:usermail] = mail
    flash[:success] = "Logged in successfully"
    path = session[:tgt_path]
    session[:tgt_path] = nil
    redirect path || "/"
  else
    flash[:danger] = "Invalid username or password (contact malvikar@gmail.com for help)"
    redirect "/login"
  end
end

get "/logout" do
  session[:usermail] = nil
  flash[:warning] = "Logged out"
  redirect "/"
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
