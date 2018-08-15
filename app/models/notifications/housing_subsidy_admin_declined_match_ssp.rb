module Notifications
  class HousingSubsidyAdminDeclinedMatchSsp < Base
    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Sent notice of #{_('Housing Subsidy Administrator')}'s decision to #{('Stabilization Services Provider')}"
    end

  end
end
