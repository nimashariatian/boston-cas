class IdentifiedClientsController < DeidentifiedClientsController
  skip_before_action :require_can_enter_deidentified_clients!
  skip_before_action :require_can_manage_deidentified_clients!
  before_action :require_can_enter_identified_clients!
  before_action :require_can_manage_identified_clients!, only: [:edit, :update, :destroy]
  before_action :load_deidentified_client, only: [:edit, :update]

  def create
    @deidentified_client = deidentified_client_source.create(clean_params(identified_client_params))
    respond_with(@deidentified_client, location: identified_clients_path)
  end

  def edit
  end

  def update
    @deidentified_client.update(clean_params(identified_client_params))
    respond_with(@deidentified_client, location: identified_clients_path)
  end

  def clean_params dirty_params
    dirty_params[:active_cohort_ids] = dirty_params[:active_cohort_ids]&.reject(&:blank?)&.map(&:to_i)
    dirty_params[:active_cohort_ids] = nil if dirty_params[:active_cohort_ids].blank?
    return dirty_params
  end

  private

    def deidentified_client_source
      DeidentifiedClient.identified.visible_to(current_user)
    end

    def identified_client_params
      params.require(:deidentified_client).permit(
        :client_identifier,
        :assessment_score,
        :agency,
        :first_name,
        :last_name,
        :dob,
        :ssn,
        :days_homeless_in_the_last_three_years,
        :veteran,
        :rrh_desired,
        :youth_rrh_desired,
        :rrh_assessment_contact_info,
        :income_maximization_assistance_requested,
        :pending_subsidized_housing_placement,
        :full_release_on_file,
        :requires_wheelchair_accessibility,
        :required_number_of_bedrooms,
        :required_minimum_occupancy,
        :requires_elevator_access,
        :active_cohort_ids => [],
      ).merge(identified: true)
    end
end
