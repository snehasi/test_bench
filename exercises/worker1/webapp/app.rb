require_relative "./lib/web_util"
require_relative "./app_helpers"

require 'sinatra'
require 'sinatra/content_for'

set :bind, '0.0.0.0'
set :root, File.dirname(__FILE__)

helpers AppHelpers

get "/" do
  slim :home
end

get "/markdown" do
  markdown :mdtest
end

get "/offers" do
  @offers = Offer.open.all
  @repos  = Repo.all
  slim :offers
end

get "/offers/new" do
  "HELLO NEW OFFERS"
end

get "/contracts" do
  @contracts = Contract.install_dirs
  slim :contracts
end

get "/account/new" do
  "HELLO NEW ACCOUNT"
end

get "/account/balance" do
  slim :account_balance
end

get "/account/history" do
  "HELLO ACCOUNT HISTORY"
end

get "/account/password" do
  "HELLO ACCOUNT PASSWORD"
end

get "/ztst" do
  slim :ztst
end


