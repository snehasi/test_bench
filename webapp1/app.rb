require 'sinatra'
require 'sinatra/content_for'
require 'slim'
require 'json'
require_relative "./app_helpers"
require_relative "./lib/bmx"

helpers AppHelpers

set :bind, '0.0.0.0'

get "/" do
  slim :home
end

get "/issues" do
  @issues = Bmx.issues
  @repos  = Bmx.repos
  require 'pry'
  binding.pry
  slim :issues
end

get "/offers" do
  @offers = Bmx.offers
  @repos  = Bmx.repos
  slim :offers
end

get "/offers/new" do
  "HELLO NEW OFFERS"
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

