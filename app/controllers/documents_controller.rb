class DocumentsController < ApplicationController
  before_action :require_login
  before_action :set_user

  def index
    case @user.Role
    when "Tenant"
      @files = FileDraft.where(CreatorID: @user.UserID, UserDeletedAt: nil)# Fetch files not labeled as deleted
      render "documents/tenant_index"
    when "Landlord"
      @files = FileDraft.where(CreatorID: @user.UserID, UserDeletedAt: nil)# Fetch files not labeled as deleted
      render "documents/landlord_index"
    else
      render plain: "Access Denied", status: :forbidden
    end
  end

  # Alot of errors in the file paths/linking in the show and download methods, I am going to leave the loggers in for now just in case we hit the issues again later - They are not doing any harm anyways
  # For the most part, my take aways are that the file paths need to be handled in different ways between the inline html presentation and the controllers
  def download
    file = FileDraft.find_by(FileID: params[:id], CreatorID: @user.UserID)

    if file
      # Ensure the path is scoped to 'public' and cleaned
      sanitized_path = Pathname.new(file.FileURLPath).cleanpath
      base_path = Rails.root.join("public")
      file_path = base_path.join(sanitized_path)

      # Prevent directory traversal and ensure the file exists
      if file_path.to_s.start_with?(base_path.to_s) && File.exist?(file_path)
        send_file file_path, filename: file.FileName, disposition: "attachment"
      else
        logger.error "File not found at path: #{file_path}"
        render plain: "File not found", status: :not_found
      end
    else
      logger.error "FileDraft not found for ID: #{params[:id]} and CreatorID: #{@user.UserID}"
      render plain: "File not found", status: :not_found
    end
  end


  def show
    @file = FileDraft.find_by(FileID: params[:id], CreatorID: @user.UserID)

    if @file
      # Correct file path by joining with 'public' (no leading / needed)
      file_path = Rails.root.join("public", @file.FileURLPath)

      if File.exist?(file_path)
        render "documents/show"
      else
        render plain: "File not found", status: :not_found
      end
    else
      render plain: "File not found", status: :not_found
    end
  end


  # I think something is wrong with this set of methods (generate, select_template, and proposal_generation) but I am unsure what to do here
  def generate
    render "documents/generate"
  end

  def select_template
    # Get the template selected by the user
    @template = params[:template]

    # Depending on the template, you can now load the appropriate form or questions
    case @template
    when "a"
      @template_name = "Payment Plan Proposal A"
      # You can also define the questions or data needed to generate the PDF here.
    when "b"
      @template_name = "Payment Plan Proposal B"
    when "c"
      @template_name = "Payment Plan Proposal C"
    else
      @template_name = "Unknown Template"
    end

    # Render a view to ask financial questions to generate a proposal
    redirect_to proposal_generation_path(template: @template)
  end

  def proposal_generation
    @template = params[:template]

    case @template
    when "a"
      @template_name = "Payment Plan Proposal A"
    when "b"
      @template_name = "Payment Plan Proposal B"
    when "c"
      @template_name = "Payment Plan Proposal C"
    else
      @template_name = "Unknown Template"
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
