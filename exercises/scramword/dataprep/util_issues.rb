require_relative "../../.lib/exchange"

WEB_DIR  = File.expand_path("../", File.dirname(__FILE__))
ENV_PATH = "../.env"
ENV_FILE = File.expand_path(ENV_PATH, WEB_DIR)

puts "EXCHANGE_DIR is #{Exchange.src_dir}"
puts "WEB DIR IS #{WEB_DIR}"
puts "ENV FILE IS #{ENV_FILE}"

Dotenv.load(ENV_FILE)

require 'json'
require 'iora'
require 'dotenv'

class UtilIssue
  attr_reader :settings, :iora

  def initialize(settings)
    @settings = settings
    @iora = Iora.new()
  end

  def get_open_issues

  end

  def close_all_issues

  end
end