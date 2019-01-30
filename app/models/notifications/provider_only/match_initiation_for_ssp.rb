module Notifications::ProviderOnly
  class MatchInitiationForSsp < ::Notifications::Base

    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('SSP')} notified of match detail"
    end
    
    def show_client_info?
      true
    end

    def allows_registration?
      false
    end
    
  end
end