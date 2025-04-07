class ScreeningsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_conversation_ID
  before_action :set_mediation
  before_action :check_mediation_status, only: [ :new, :create ]

  def new
    @screening = ScreeningQuestion.new
  end

  def create
    @conversation_id = params[:conversation_id]
    @screening = ScreeningQuestion.new(screening_params)
    @primary_message_group = PrimaryMessageGroup.find_by(ConversationID: @conversation_id)

    if @screening.save
      # Flag for review by admin
      if @screening.InterpreterNeeded == true ||
        @screening.DisabilityAccommodation == true ||
        @screening.ConflictOfInterest == true ||
        @screening.NeedToConsult == true ||
        @screening.Unsafe == true ||
        @screening.SpeakOnOwnBehalf == false

        @screening.update!(flagged: true)
      end
      # Update associated screeningID
      if @user.Role == "Landlord"
        @primary_message_group.update!(LandlordScreeningID: @screening.ScreeningID)
      elsif @user.Role == "Tenant"
        @primary_message_group.update!(TenantScreeningID: @screening.ScreeningID)
      else
        redirect_to root_path, alert: "Unauthorized role"
      end
      redirect_to message_path(@conversation_id), notice: "Screening completed successfully."
    else
      render :new
    end
  end

  private

  def set_mediation
    @mediation = PrimaryMessageGroup.find_by(ConversationID: @conversation_id)
  end

  # Prevent users from completing screening questions after mediation has ended (edge case)
  def check_mediation_status
    mediation = PrimaryMessageGroup.find_by(ConversationID: @conversation_id)

    if mediation&.deleted_at.present?
      redirect_to mediation_ended_prompt_path(@conversation_id)
    end
  end

  def require_login
    unless session[:user_id]
      redirect_to login_path, alert: "You must be logged in to access the dashboard."
    end
  end

  def set_user
    @user = User.find(session[:user_id])
  end

  def set_conversation_ID
    @conversation_id = params[:conversation_id]
  end

  def screening_params
    params.require(:screening_question).permit(
      :InterpreterNeeded, :InterpreterLanguage,
      :DisabilityAccommodation, :DisabilityExplanation,
      :ConflictOfInterest, :SpeakOnOwnBehalf,
      :NeedToConsult, :ConsultExplanation,
      :RelationshipToOtherParty, :Unsafe, :UnsafeExplanation, :UserID, :conversation_id
    )
  end
end
