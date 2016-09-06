class NotificationsMailer < ApplicationMailer

  def match_recommendation_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] New Housing Recommendation - Requires Your Action')
  end

  def match_recommendation_client notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] New Housing Opportunity')
  end

  def match_recommendation_housing_subsidy_admin notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] New Housing Recommendation')
  end

  def match_recommendation_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] New Housing Recommendation - Requires Your Action')
  end

  def schedule_criminal_hearing_housing_subsidy_admin notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Housing Recommendation - Requires Your Action')
  end
  
  def record_client_housed_date_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Housing Recommendation Approved - Requires Your Action')
  end
  
  def confirm_match_success_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Housing Recommendation - Requires Final Approval')
  end
  
  def criminal_hearing_scheduled_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Hearing Scheduled')
  end
  
  def criminal_hearing_scheduled_client notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Hearing Scheduled')
  end
  
  def criminal_hearing_scheduled_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Hearing Scheduled')
  end
  
  def housing_subsidy_admin_decision_client notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: 'Decision from Housing Subsidy Administrator')
  end
  
  def housing_subsidy_admin_accepted_match_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Match Accepted by HSA')
  end
  
  def housing_subsidy_admin_declined_match_shelter_agency notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Match Declined by HSA')
  end

  def confirm_shelter_agency_decline_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Match Declined by Shelter Agency - Requires Your Action')
  end

  def confirm_housing_subsidy_admin_decline_dnd_staff notification
    @notification = notification
    @match = notification.match
    @contact = notification.recipient
    mail(to: @contact.email, subject: '[CAS] Match Declined by HSA - Requires Your Action')
  end

  
end