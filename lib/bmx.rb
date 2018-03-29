require 'json'

class Bmx
  class << self
    def issues
      JSON.parse(`bmx issue list`) || []
    end

    def repos
      JSON.parse(`bmx repo list`) || []
    end

    def users
      JSON.parse(`bmx user list`) || []
    end
  end
end