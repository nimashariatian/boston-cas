module Notifications
  class HousingSubsidyAdminDecisionClient < Base
    # Notification sent to a client of a decision made by the housing subsidy administrator
    
    def self.create_for_match! match
      match.client_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      'Client sent notice of Housing Subsidy Administrator\'s decision.'
    end

    def should_expire?
      false
    end
    
  end
end
