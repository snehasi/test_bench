require 'csv'
require 'yaml'
require 'dotenv'

SCRIPT_DIR = File.dirname(__FILE__)
ENV_PATH = "../.env"
CSV_PATH = "../../../data/trivia1.csv"
ENV_FILE = File.expand_path(ENV_PATH, SCRIPT_DIR)
CSV_FILE = File.expand_path(CSV_PATH, SCRIPT_DIR)

Dotenv.load(ENV_FILE)

EXCHANGE_DIR = File.expand_path(ENV["EXCHANGE_DIR"])
TRIAL_DIR    = File.expand_path(ENV["TRIAL_DIR"])
SETTINGS     = File.expand_path("./.trial_data/Settings.yml", TRIAL_DIR)

class PrepSettings
  class << self
    def method_missing(m)
      settings[m.to_sym]
    end

    def settings
      base_settings = {trial_repo_dir: TRIAL_DIR}
      @settings ||= yaml_settings.merge(base_settings)
    end

    private

    def yaml_settings
       YAML.load_file(SETTINGS).transform_keys {|k| k.to_sym}
    end
  end
end
PS = PrepSettings

class PrepData
  class << self

    Scramble = Struct.new(:qstring, :astring) do
      def quiz
        "UnScramble this Word: #{qstring}"
      end

      def quiz_word
        qstring.gsub(" ", "")
      end

      def quiz_fn(level)
        "#{quiz_word}_#{level}.md"
      end

      def answer
        astring
      end

      def answer_line
        "#{qstring} |> #{astring}"
      end

      def hint(level)
        return "" if level == 0
        answer[0..level-1]
      end
    end

    def scrambles(max_lines = 10)
      data = []
      count = 0
      CSV.foreach(CSV_FILE) do |row|
        if row[1].start_with?("UnScramble")
          data.append(row_2_struct(row))
          count += 1
        end
        break if count >= max_lines
      end
      data
    end

    private

    def row_2_struct(row)
      qstr = row[1].gsub("UnScramble this Word:", "").strip
      astr = row[2]
      Scramble.new(qstr, astr)
    end
  end
end
PD = PrepData

