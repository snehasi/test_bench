require_relative "../.lib/exchange"
require_relative "./app"

Exchange.load_rails

run Sinatra::Application
