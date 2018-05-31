class CodeIssue

  attr_reader :issue, :sequence

  def initialize(issue)
    @issue = issue.stringify_keys
  end

  def [](arg)
    @issue[arg]
  end

  def keyword_for(user_uuid)
    return issue["keyword1"] if issue["users1"].include?(user_uuid)
    return issue["keyword2"] if issue["users2"].include?(user_uuid)
    nil
  end

  def for_user?(user_uuid)
    users1 = issue["users1"] || []
    users2 = issue["users2"] || []
    users1.include?(user_uuid) || users2.include?(user_uuid)
  end
end

class CodeWord

  attr_reader :data

  def initialize
    @data = load_yaml_files
  end

  def issues
    @issues ||= @data.transform_values {|v| CodeIssue.new(v)}
  end

  def issues_for_user(user_uuid)
    issues.select do |_k, v|
      v.for_user?(user_uuid)
    end
  end

  def issue_sequence_for(keyword1, keyword2)
    issue1 = issue_for_keyword(keyword1)
    issue2 = issue_for_keyword(keyword2)
    return issue1["sequence"] if issue1 == issue2
    nil
  end

  def solution_for(keyword1, keyword2)
    seq = issue_sequence_for(keyword1, keyword2)
    return data[seq]["solution"] if seq
    nil
  end

  private

  def issue_for_keyword(keyword)
    # noinspection RubyArgCount
    keycap = keyword.capitalize.chomp.strip
    data.select do |_k, v|
      v["keyword1"] == keycap || v["keyword2"] == keycap
     end.keys.first
  end

  def has_word(issue, keyword)
    issue["keyword1"] == keyword || issue["keyword2"] == keyword
  end

  def load_yaml_files
    files = Dir.glob(TS.trial_dir + "/.trial_data/**/code_hash*yml")
    files.reduce({}) do |acc, file|
      acc.merge YAML.load_file(file)
    end
  end
end