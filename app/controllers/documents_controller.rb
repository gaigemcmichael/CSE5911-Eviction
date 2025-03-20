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
