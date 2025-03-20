class DocumentsController < ApplicationController
  before_action :require_login
  before_action :set_user

  def index
    case @user.Role
    when "Tenant"
      @files = FileDraft.where(CreatorID: @user.UserID, UserDeletedAt: nil)# Fetch files not labeled as deleted
      render "documents/tenant_index"
    when "Landlord"
      render "documents/landlord_index"
    else
      render plain: "Access Denied", status: :forbidden
    end
  end

  def download
    file = FileDraft.find_by(FileID: params[:id], CreatorID: @user.UserID)

    if file && File.exist?(Rails.root.join(file.FileURLPath))
      send_file Rails.root.join(file.FileURLPath), filename: file.FileName, disposition: "attachment"
    else
      render plain: "File not found", status: :not_found
    end
  end

  #I think something is wrong with this set of methods (generate, select_template, and proposal_generation) but I am unsure what to do here
  def generate
    render "documents/generate"
  end

  def select_template
    # Get the template selected by the user
    @template = params[:template]

    # Depending on the template, you can now load the appropriate form or questions
    case @template
    when 'a'
      @template_name = 'Payment Plan Proposal A'
      # You can also define the questions or data needed to generate the PDF here.
    when 'b'
      @template_name = 'Payment Plan Proposal B'
    when 'c'
      @template_name = 'Payment Plan Proposal C'
    else
      @template_name = 'Unknown Template'
    end

    # Render a view to ask financial questions to generate a proposal
    redirect_to proposal_generation_path(template: @template)
  end

  def proposal_generation
    @template = params[:template]
    
    case @template
    when 'a'
      @template_name = 'Payment Plan Proposal A'
    when 'b'
      @template_name = 'Payment Plan Proposal B'
    when 'c'
      @template_name = 'Payment Plan Proposal C'
    else
      @template_name = 'Unknown Template'
    end

    # Here we can add logic to actually begin the payment plan info filling
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
end
