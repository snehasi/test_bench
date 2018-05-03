require 'csv'
require 'yaml'
require 'dotenv'

LIB_DIR  = File.dirname(__FILE__)
ENV_FILE = "#{EXERCISE_DIR}/.env"

Dotenv.load(ENV_FILE)

TRIAL_TRACKER_DIR = File.expand_path(ENV["TRIAL_TRACKER_DIR"])
TRIAL_TRACKER_URL = ENV["TRIAL_TRACKER_URL"]
SETTINGS       = File.expand_path("./.trial_data/Settings.yml", TRIAL_TRACKER_DIR)
