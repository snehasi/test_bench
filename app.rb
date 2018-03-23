require 'sinatra'
require 'slim'
require_relative "./app_helpers"

helpers AppHelpers

set :bind, '0.0.0.0'

get "/" do
  slim :home
end

get "/issues" do
  slim :issues
end

get "/offers" do
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

