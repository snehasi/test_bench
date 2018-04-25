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

get "/account" do
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
    redirect "/"
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

# ----- testing -----

get "/ztst" do
  slim :ztst
end
