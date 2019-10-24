###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications::Four
  class ConfirmHousingSubsidyAdminDeclineDndStaff < ::Notifications::ConfirmHousingSubsidyAdminDeclineDndStaff

    def decision
      match.four_confirm_housing_subsidy_admin_decline_dnd_staff_decision
    end

  end
end