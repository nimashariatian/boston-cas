###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchEvents
  class Created < Base
    # Just a simple event to mark the birth of the match

    def name
      'New match recommendation generated by CAS'
    end

    def contact_name
      'CAS Match Engine'
    end

  end
end