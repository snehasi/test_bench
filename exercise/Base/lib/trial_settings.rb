require 'yaml'

class TrialSettings
  class << self
    def method_missing(m)
      settings[m.to_sym]
    end

    def settings
      default_settings = {
        trial_dir: File.expand_path(TRIAL_DIR),
      }
      @settings ||= default_settings.merge(generator_settings).merge(base_settings)
    end

    private

    def generator_settings
      dir  = File.expand_path("./.trial_data", TRIAL_DIR)
      Dir.glob("#{dir}/[a-z]*settings*.yml").reduce({}) do |acc, fn|
        acc.merge(yaml_settings(fn))
      end
    end

    def base_settings
      base = File.expand_path("./.trial_data/Settings.yml", TRIAL_DIR)
      yaml_settings(base)
    end

    def yaml_settings(file)
      if File.exists?(file)
        YAML.load_file(file).transform_keys {|k| k.to_sym}
      else
        {}
      end
    end
  end
end

TS = TrialSettings
