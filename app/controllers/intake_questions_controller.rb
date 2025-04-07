class IntakeQuestionsController < ApplicationController
    before_action :require_login
    before_action :set_user
    before_action :set_conversation_ID

    def new
      @intake_question = IntakeQuestion.new
    end
  
    def create
      @intake_question = IntakeQuestion.new(intake_question_params)
      @intake_question.UserID = @user.UserID
  
      if @intake_question.save
        @conversation_id = params[:conversation_id]
        conversation = PrimaryMessageGroup.find_by(
            TenantID: @user.UserID,
            deleted_at: nil
          )        
        conversation.update!(IntakeID: @intake_question.IntakeID)
        redirect_to messages_path, notice: "Intake questions completed successfully. You can now proceed to your negotiations."
        else 
            redirect_to root_path, alert: "An error occured."
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
  
    def intake_question_params
      params.require(:intake_question).permit(
        :Reason, :DescribeCause, :BestOption, :Section8,
        :MoneyOwed, :TotalCostOrMonthly, :MonthlyRent,
        :DateDue, :PayableToday, :conversation_id
      )
    end
  end