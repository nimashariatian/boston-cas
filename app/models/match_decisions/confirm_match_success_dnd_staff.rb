module MatchDecisions
  class ConfirmMatchSuccessDndStaff < Base
    
    # validate :note_present_if_status_rejected

    def statuses
      {pending: 'Pending', confirmed: 'Confirmed', rejected: 'Rejected'}
    end
    
    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then 'DND to confirm match success'
      when :confirmed then 'DND confirms match success'
      when :rejected then 'Match rejected by DND'
      end
    end

    def step_name
      'Confirm Match Success'
    end

    def actor_type
      'DND'
    end
    
    def editable?
      super && status !~ /confirmed|rejected/
    end

    def initialize_decision!
      update status: 'pending'
      Notifications::ConfirmMatchSuccessDndStaff.create_for_match! match
    end

    def accessible_by? contact
      contact.user_admin? ||
      contact.user_dnd_staff?
    end

    private def note_present_if_status_rejected
      if note.blank? && status == 'rejected'
        errors.add :note, 'Please note why the match is declined.'
      end
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def confirmed
        match.succeeded!
      end
      
      def rejected
        match.rejected!
        # TODO maybe rerun the matching engine for that vancancy and client
      end
    end
    private_constant :StatusCallbacks
    
  end
  
end
