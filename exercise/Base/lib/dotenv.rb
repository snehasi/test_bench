require 'dotenv'

def dotenv_trial_dir(path)
  base        = File.expand_path("./.env", path)
  parent      = File.expand_path("../.env", path)
  grandparent = File.expand_path("../../.env", path)
  targets = [base, parent, grandparent]
  file = Dir.glob(targets).first
  puts "ENV_FILE IS #{file}"
  Dotenv.load(file)
  ENV["TRIAL_DIR"]
end
