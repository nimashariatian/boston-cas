module MatchProgressUpdates
  class Base < ::ActiveRecord::Base
    self.table_name = 'match_progress_updates'
    has_paper_trail
    acts_as_paranoid
    attr_accessor :working_with_client
    validates_presence_of :response, :client_last_seen, if: :submitting?
    validate :note_required_if_other!

    DND_INTERVAL = if Rails.env.production?
      1.weeks
    else
      1.days
    end

    STALLED_INTERVAL = if Rails.env.production?
      1.months
    else
      2.days
    end

    def to_partial_path
      'match_progress_updates/progress_update'
    end

    belongs_to :match,
      class_name: ClientOpportunityMatch.name,
      inverse_of: :status_updates

    belongs_to :notification,
      class_name: Notifications::Base.name
      
    belongs_to :contact,
      inverse_of: :status_updates
    delegate :name, to: :contact, prefix: true

    belongs_to :decision,
      class_name: MatchDecisions::Base.name,
      inverse_of: :status_updates

    scope :incomplete, -> do
      mpu_t = arel_table
      joins(:match).
      merge(ClientOpportunityMatch.stalled).
      where(submitted_at: nil)
      # where(mpu_t[:due_at].lteq(Time.new))
    end

    scope :incomplete_for_contact, -> (contact_id:) do
      incomplete.
      where(contact_id: contact_id)
    end

    scope :complete, -> do
      where.not(submitted_at: nil)
    end

    # any status updates that have been requested over DND interval ago (currently 1 week)
    scope :should_notify_dnd, -> do
      mpu_t = arel_table
      incomplete.
      where.not(requested_at: nil).
      where(mpu_t[:requested_at].lteq(DND_INTERVAL.ago)).
      where(dnd_notified_at: nil)
    end

    alias_attribute :timestamp, :submitted_at

    def name
      raise 'Abstract method'
    end

    def other_response
      'Other (note required)'
    end

    def still_active_responses
      [
        'Client searching for unit',
        'Client has submitted request for tenancy',
        'Client is waiting for project/sponsor based unit to become available',
        'SSP/HSA waiting on documentation',
        'SSP/HSA  CORI mitigation',
        'Client has submitted Reasonable Accomodation',
        other_response,
      ]
    end

    def no_longer_active_responses
      [
        'Client disappeared',
        'Client incarcerated',
        'Client in medical institution',
        'Client declining services',
        'SSP/HSA unable to contact client',
        other_response,
      ]
    end

    def submit!
      @submitting = true
      save!
    ensure
      @submitting = false
    end

    def submitting?
      @submitting
    end

    def note_editable_by? editing_contact
      editing_contact &&
      contact == editing_contact 
    end

    def is_editable?
      response.blank? && match.stalled?
    end

    def should_notify_dnd_of_lateness?
      is_editable? && dnd_notified_at.blank? && requested_at <= DND_INTERVAL.ago
    end

    def self.incomplete_for_contact?(contact_id:, match_id:)
      incomplete_for_contact(contact_id: contact_id).
        where(match_id: match_id).exists?
    end

    def self.create_for_match! match
      match.public_send(self.match_contact_scope).each do |contact|  
        create!(
          match: match, 
          contact: contact,
        )
      end
    end

    # Re-send the same request if we requested it before, but haven't had a response
    # in a reasonable amount of time
    def resend_update_request?
      requested_at.present? && submitted_at.blank? && requested_at < STALLED_INTERVAL.ago
    end

    # Ask for a status update if we submitted one a long time ago and haven't asked again for a while
    def create_new_update_request?
      submitted_at.present? && submitted_at < STALLED_INTERVAL.ago && requested_at < STALLED_INTERVAL.ago
    end
    
    def never_sent?
      requested_at.blank?
    end

    def self.send_notifications
      # Get SSP & Shelter agency contacts for stalled matches
      # if we have un-submitted but requested status update where the requested date is less than INTERVAL.ago - queue to send same request again, and update the requested date
      # if we have a submitted progress update with a response less than INTERVAL.ago - create a new update request
      matches = self.joins(:match).merge(ClientOpportunityMatch.stalled).
        distinct.pluck(:contact_id, :match_id)
      matches.each do |contact_id, match_id|
        # Determine next notification number
        notification_number = self.where(
          contact_id: contact_id,
          match_id: match_id,
        ).count
        progress_update = self.where(
          contact_id: contact_id,
          match_id: match_id,
        ).order(id: :desc).first
        requested_at = Time.now
        decision_id = progress_update.match.current_decision.id
        if progress_update.never_sent?
          notification = Notifications::ProgressUpdateRequested.create_for_match!(
            progress_update.match, 
            contact: progress_update.contact
          )
          progress_update.update(
            decision_id: decision_id,
            requested_at: requested_at,
            notification_id: notification.id,
            notification_number: 1,
            dnd_notified_at: nil,
          )
        elsif progress_update.resend_update_request?
          # Re-send same request
          # Bump requested_at
          notification = Notifications::Base.find(progress_update.notification_id)
          notification.deliver
          progress_update.update(
            decision_id: decision_id,
            requested_at: requested_at,
            dnd_notified_at: nil,
          )
        elsif progress_update.create_new_update_request?
          # Create a new request
          notification = Notifications::ProgressUpdateRequested.create_for_match!(
            progress_update.match, 
            contact: progress_update.contact
          )
          new_request = create(
            inheritance_column: progress_update.inheritance_column,
            match_id: progress_update.match_id,
            contact_id: progress_update.contact_id,
            notification_id: notification.id,
            notification_number: notification_number,
            decision_id: decision_id,
            requested_at: requested_at,
          )
        end
      end
    end
    
    def self.batch_should_notify_dnd
      matches = ClientOpportunityMatch.where(id: should_notify_dnd.select(:match_id))
      
      Notifications::DndProgressUpdateLate.create_for_matches!(matches)
      # Notify DnD for each match
      should_notify_dnd.update_all(dnd_notified_at: Time.now)
    end

    def self.match_contact_scope
      raise 'Abstract method'
    end

    def note_required_if_other!
      if response.present? && response.include?(other_response) && note.strip.blank?
        errors.add :note, "must be filled in if choosing 'Other'"
      end
    end

  end
end
