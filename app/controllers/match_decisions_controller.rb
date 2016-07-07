class MatchDecisionsController < ApplicationController
  include HasMatchAccessContext

  before_action :require_match_access_context!
  before_action :find_match!
  before_action :find_decision!
  before_action :authorize_decision!
  
  def show
    @client = @match.client
    @opportunity = @match.opportunity
    if params[:notification_id].present?
      @notification = @access_context.notification
    end
    render 'matches/show'
  end
  
  def update
    if !@decision.editable?
      flash[:alert] = 'Sorry, a response has already been recorded and this step is now locked.'
      redirect_to access_context.match_decision_path(@match, @decision)
    elsif @match.closed?
      flash[:alert] = 'Sorry, that match has already been closed.'
      redirect_to access_context.match_path(@match)
    elsif @decision.update(decision_params)
      @decision.record_action_event! contact: current_contact
      @decision.run_status_callback!
      flash[:notice] = "Thank you, your response has been entered." unless request.xhr?
      redirect_to access_context.match_path(@match)
    else
      flash[:error] = "Please review the form problems below."
      render 'matches/show'
    end
  end

  private

    def find_match!
      @match = match_scope.find params[:match_id]
    end

    def find_decision!
      @decision = @match.decision_from_param params[:id]
    end
    
    def authorize_decision!
      unless @decision.accessible_by? current_contact
        flash[:alert] = 'Sorry, you are not authorized to access that.'
        redirect_to access_context.match_path(@match)
      end
    end
    
    def decision_params
      @decision.whitelist_params_for_update params
    end

end