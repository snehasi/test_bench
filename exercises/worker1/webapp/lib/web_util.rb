# require_relative "./bmx"
require_relative "../../.lib/exchange"

WEB_DIR  = File.expand_path("../", File.dirname(__FILE__))
ENV_PATH = "../.env"
ENV_FILE = File.expand_path(ENV_PATH, WEB_DIR)

puts "WEB DIR IS #{WEB_DIR}"
puts "ENV FILE IS #{ENV_FILE}"

Dotenv.load(ENV_FILE)

puts "EXCHANGE_DIR is #{Exchange.src_dir}"

require 'slim'
require 'json'
require 'dotenv'
