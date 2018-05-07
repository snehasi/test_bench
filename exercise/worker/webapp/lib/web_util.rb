require 'bundler'
Bundler.setup(:test_bench)

require_relative "../../../Base/lib/dotenv"
require_relative "../../../Base/lib/exchange"
require_relative "../../../Base/lib/trial_settings"

WEB_DIR  = File.expand_path("../", File.dirname(__FILE__))

puts "WEB DIR IS #{WEB_DIR}"

Dotenv.load(ENV_FILE)

puts "EXCHANGE_DIR is #{Exchange.src_dir}"

require 'slim'
require 'json'
require 'dotenv'
require 'iora'
require 'time'
