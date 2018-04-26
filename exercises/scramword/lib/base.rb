require 'csv'
require 'yaml'
require 'dotenv'

LIB_DIR  = File.dirname(__FILE__)
ENV_PATH = "../.env"
CSV_PATH = "../../../data/trivia1.csv"
ENV_FILE = File.expand_path(ENV_PATH, LIB_DIR)
CSV_FILE = File.expand_path(CSV_PATH, LIB_DIR)

Dotenv.load(ENV_FILE)

TRIAL_DIR    = File.expand_path(ENV["TRIAL_DIR"])
SETTINGS     = File.expand_path("./.trial_data/Settings.yml", TRIAL_DIR)
