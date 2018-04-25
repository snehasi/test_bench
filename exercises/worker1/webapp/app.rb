require_relative "./lib/web_util"
require_relative "./app_helpers"

require 'sinatra'
require 'sinatra/content_for'

set :bind, '0.0.0.0'
set :root, File.dirname(__FILE__)

helpers AppHelpers

# ----- core app -----

get "/" do
  slim :home
end

get "/offers" do
  @offers = Offer.open.all
  @repos  = Repo.all
  slim :offers
end

get "/contracts" do
  @contracts = Contract.install_dirs
  slim :contracts
end

# ----- user account -----

get "/account/new" do
  "HELLO NEW ACCOUNT"
end

get "/account/balance" do
  slim :account_balance
end

# ----- login/logout -----

get "/login" do
  slim :login
end

post "/login" do
  session[:usermail] = "andy@r210.com"
  redirect "/"
end

get "/logout" do
  session[:usermail] = nil
  redirect "/"
end

# ----- testing -----

get "/ztst" do
  slim :ztst
end
