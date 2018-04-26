class TrialIssue

  attr_reader :settings, :iora

  def initialize(settings)
    @settings = settings
    # @iora = Iora.new()
  end

  def get_open_issues
  end

  def close_all_issues
  end
end