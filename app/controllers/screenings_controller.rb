class ScreeningsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_conversation_ID

  def new
    @screening = ScreeningQuestion.new  
  end

  def create
    puts "DEBUG: Conversation ID: #{@conversation_id}" # This will output the value of the conversation_id to your server logs

    @screening = ScreeningQuestion.new(screening_params)
    if @screening.save
      if @user.Role == 'Landlord'
        redirect_to landlord_show_path(conversation_id: @conversation_id), notice: 'Screening completed successfully'
      elsif @user.Role == 'Tenant'
        redirect_to tenant_show_path(conversation_id: @conversation_id), notice: 'Screening completed successfully'
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
      :RelationshipToOtherParty, :Unsafe, :UnsafeExplanation, :UserID
    )
  end
end