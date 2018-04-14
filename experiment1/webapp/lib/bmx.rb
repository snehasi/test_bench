require 'json'

class Bmx
  class << self
    def issues
      JSON.parse(`bmx issue list_details`) || []
    end

    def repos
      JSON.parse(`bmx repo list_details`) || []
    end

    def users
      JSON.parse(`bmx user list_details`) || []
    end

    def offers
      JSON.parse(`bmx offer list_details`) || []
    end
  end
end