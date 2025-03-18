class ScreeningsController < ApplicationController
<<<<<<< HEAD
  def complete_screening
    render plain: "Screening Questions WIP: Please complete your screening questions."
  end
end
=======
  before_action :require_login
  before_action :set_user
  before_action :set_conversation_ID

  def new
    @screening = ScreeningQuestion.new  
  end

  def create
    @conversation_id = params[:conversation_id]
    @screening = ScreeningQuestion.new(screening_params)
    @primary_message_group = PrimaryMessageGroup.find_by(ConversationID: @conversation_id)

    if @screening.save
      if @user.Role == 'Landlord'
        @primary_message_group.update(LandlordScreeningID: @screening.ScreeningID)
        redirect_to "/messages/#{params[:conversation_id]}"
      elsif @user.Role == 'Tenant'
        @primary_message_group.update(TenantScreeningID: @screening.ScreeningID)
        redirect_to "/messages/#{params[:conversation_id]}"
      else
        redirect_to root_path, alert: 'Unauthorized role'
      end
    else
      render :new
    end
  end

  private

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
>>>>>>> origin/main
