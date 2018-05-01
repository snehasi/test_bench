require_relative './base'

class TrialSettings
  class << self
    def method_missing(m)
      settings[m.to_sym]
    end

    def settings
      base_settings = {
        trial_repo_dir: TRIAL_REPO_DIR,
        trial_repo_url: TRIAL_REPO_URL
      }
      @settings ||= base_settings.merge(yaml_settings)
    end

    private

    def yaml_settings
       YAML.load_file(SETTINGS).transform_keys {|k| k.to_sym}
    end
  end
end

TS = TrialSettings
