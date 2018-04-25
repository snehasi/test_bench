require 'json'

class Bmx
  class << self
    def issues
      Issue.all
    end

    def repos
      Repo.all
    end

    def users
      User.all
    end

    def offers
      Offer.all
    end
  end
end