# app/controllers/documents_controller.rb
require "fileutils"
require "pathname"
require "securerandom"
require "prawn"
require "prawn/table"

class DocumentsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_conversation_context, only: [ :intake_template_view ]


  def intake_template_view
  end
  # delete files
  def destroy
    file = FileDraft.find_by(FileID: params[:id], CreatorID: @user[:UserID])
    return render plain: "File not found", status: :not_found unless file


    if FileDraft.column_names.include?("UserDeletedAt")
      file.update!(UserDeletedAt: Time.current)
    else
      delete_physical_file(file)
      file.destroy!
    end

    redirect_to documents_path, notice: "Document deleted."
  end

  def index
    scope = FileDraft.where(CreatorID: @user[:UserID])
    scope = scope.where(UserDeletedAt: nil) if FileDraft.column_names.include?("UserDeletedAt")

    @files =
      if FileDraft.column_names.include?("created_at")
        scope.order(created_at: :desc)
      elsif FileDraft.column_names.include?("CreatedAt")
        scope.order(Arel.sql("[CreatedAt] DESC"))
      elsif FileDraft.column_names.include?("UpdatedAt")
        scope.order(Arel.sql("[UpdatedAt] DESC"))
      else
        scope.order(Arel.sql("[FileID] DESC"))
      end
  end

  def new; end

  # Upload handler
  def create
    uploaded = params[:file] || params.dig(:document, :file)
    unless uploaded
      redirect_to new_document_path, alert: "Please choose a file to upload." and return
    end

    ext = File.extname(uploaded.original_filename).downcase
    allowed = %w[
      .pdf .doc .docx .txt .csv .xlsx .xls .ppt .pptx .rtf
      .png .jpg .jpeg .gif .bmp .tiff .heic
      .zip .rar .7z .json .xml .md .mp3 .mp4 .wav .mov .avi
    ]
    unless allowed.include?(ext)
      redirect_to new_document_path, alert: "Unsupported file type (#{ext})." and return
    end
    if uploaded.size.to_i > 25.megabytes
      redirect_to new_document_path, alert: "File too large (max 25 MB)." and return
    end

    file_id = SecureRandom.uuid
    dir = Rails.root.join("public", "userFiles")
    FileUtils.mkdir_p(dir)
    dest = dir.join("#{file_id}#{ext}")
    File.open(dest, "wb") { |f| f.write(uploaded.read) }
    pk_name, pk_value = next_filedraft_pk_value
    attrs = {

      FileName:     File.basename(uploaded.original_filename, ".*"),
      FileTypes:    ext.delete("."),
      FileURLPath:  "userFiles/#{file_id}#{ext}",
      CreatorID:    @user[:UserID],
      TenantSignature: false,
      LandlordSignature: false
    }
    attrs[pk_name] = pk_value if pk_name && pk_value

    FileDraft.create!(attrs)

    redirect_to documents_path, notice: "File uploaded."
  end

  def show
    @file = find_file_for_user(params[:id])
    render plain: "File not found", status: :not_found unless @file
  end

  # GET /documents/:id/sign
def sign
  @file = FileDraft.where(FileID: params[:id])
  @file = @file.where(UserDeletedAt: nil) if FileDraft.column_names.include?("UserDeletedAt")
  @file = @file.first

  return redirect_to documents_path, alert: "File not found or not available." unless @file
end

# POST /documents/:id/apply_signature
def apply_signature
  file_scope = FileDraft.where(FileID: params[:id])
  file_scope = file_scope.where(UserDeletedAt: nil) if FileDraft.column_names.include?("UserDeletedAt")
  file = file_scope.first
  return redirect_to documents_path, alert: "File not found or not available." unless file

  case @user.Role
  when "Tenant"
    file.update!(TenantSignature: true) unless file.TenantSignature
    msg = "Tenant signature applied."
  when "Landlord"
    file.update!(LandlordSignature: true) unless file.LandlordSignature
    msg = "Landlord signature applied."
  else
    return redirect_to documents_path, alert: "Only tenants or landlords can sign."
  end

  redirect_to documents_path, notice: msg
end


  # download of the stored file
  def download
    file = find_file_for_user(params[:id])
    return render plain: "File not found (record)", status: :not_found unless file

    base_path = Rails.root.join("public")
    rel_path  = Pathname.new(file.FileURLPath).cleanpath
    path      = base_path.join(rel_path)

    size = File.exist?(path) ? File.size(path) : -1
    Rails.logger.info "[DL] path=#{path} exists=#{File.exist?(path)} size=#{size}"

    unless path.to_s.start_with?(base_path.to_s) && File.exist?(path)
      return render plain: "File not found (#{path})", status: :not_found
    end
    if size <= 0
      return render plain: "Generated file is empty (#{path})", status: :unprocessable_entity
    end

    mime_type = begin
      Marcel::MimeType.for(path.to_path, extension: File.extname(path))
    rescue StandardError
      nil
    end
    disposition = mime_type == "application/pdf" ? "inline" : "attachment"

    send_file path,
              filename: "#{file.FileName}#{File.extname(path)}",
              type: mime_type || "application/octet-stream",
              disposition: disposition
  end

  def generate_filled_template
    conv_id   = params[:conversation_id]
    landlord  = params[:landlord_name].to_s
    tenant    = params[:tenant_name].to_s
    address   = params[:address].to_s
    nego_date = begin
      (params[:negotiation_date].presence || Date.today).to_date
    rescue StandardError
      Date.today
    end
    best      = (@intake&.BestOption || params[:best_option]).to_s

    # payment schedule
    schedule = []
    params.to_unsafe_h.each do |key, value|
      next unless key.to_s =~ /\Aamount(\d+)\z/

      index = Regexp.last_match(1).to_i
      amount = value.to_s
      due_on = params["date#{index}"]
      schedule << [ index, amount, due_on ]
    end
    schedule.sort_by! { |i, _, _| i }

    additional = params[:additional_provisions].presence || "None"
    tenant_sig = params[:tenant_signature].to_s
    land_sig   = params[:landlord_signature].to_s

    file_id = SecureRandom.uuid
    ext     = ".pdf"
    dir     = Rails.root.join("public", "userFiles")
    FileUtils.mkdir_p(dir)
    dest    = dir.join("#{file_id}#{ext}")

    # Generate the PDF
    require "prawn"
    Prawn::Document.generate(dest.to_s, margin: 54) do |pdf|
      pdf.text (best == "Move Out" ? "Agreement to Vacate" : "Pay and Stay Agreement"),
               size: 20, style: :bold, align: :center
      pdf.move_down 14

      pdf.text "Date: #{nego_date.strftime('%B %d, %Y')}"
      pdf.move_down 8

      pdf.text "Landlord: #{landlord}"
      pdf.text "Tenant:   #{tenant}"
      pdf.text "Address:  #{address}"
      pdf.move_down 14

      if best == "Move Out"
        vacate_date = params[:vacate_date].present? ? (Date.parse(params[:vacate_date]) rescue nil) : nil
        pdf.text "Vacate Date: #{vacate_date ? vacate_date.strftime('%B %d, %Y') : 'N/A'}"
        pdf.move_down 10
      end

      if schedule.any?
        pdf.text "Payment Schedule", style: :bold
        pdf.move_down 6
        data = [ [ "#", "Amount (USD)", "Due Date" ] ] +
               schedule.map do |i, amt, dat|
                 d = (dat.present? ? (Date.parse(dat) rescue dat) : "")
                 [ i.to_s, (amt.presence || ""), (d.is_a?(Date) ? d.strftime("%Y-%m-%d") : d) ]
               end
        pdf.table(data, header: true, width: pdf.bounds.width) do
          row(0).font_style = :bold
        end
        pdf.move_down 12
      end

      pdf.text "Additional Provisions", style: :bold
      pdf.move_down 4
      pdf.text additional
      pdf.move_down 18

      pdf.stroke_horizontal_rule
      pdf.move_down 10

      pdf.text "Tenant Signature: #{tenant_sig}" if tenant_sig.present?
      pdf.text "Landlord Signature: #{land_sig}" if land_sig.present?

      pdf.move_down 8
      pdf.text "Conversation ID: #{conv_id}", size: 9, color: "555555" if conv_id.present?
    end

    pk_name, pk_value = next_filedraft_pk_value

    attrs = {
      FileID: file_id,
      FileName: "Generated Agreement",
      FileTypes: "pdf",
      FileURLPath: "userFiles/#{file_id}#{ext}",
      CreatorID: @user[:UserID],
      TenantSignature: tenant_sig.present?,
      LandlordSignature: land_sig.present?
    }
    attrs[pk_name] = pk_value if pk_name && pk_value

    FileDraft.create!(attrs)

    redirect_to documents_path, notice: "Document generated."
  end


  private

  def delete_physical_file(file)
    rel = Pathname.new(file.FileURLPath.to_s).cleanpath
    base = Rails.root.join("public")
    path = base.join(rel)
    if path.to_s.start_with?(base.to_s) && File.exist?(path)
      File.delete(path) rescue nil
    end
  end

  def find_file_for_user(id)
    scope = FileDraft.where(FileID: id)
    scope = scope.where(UserDeletedAt: nil) if FileDraft.column_names.include?("UserDeletedAt")

    file = scope.first
    return unless file
    return file if file.CreatorID == @user[:UserID]

    attachments = FileAttachment.where(FileID: file.FileID)
    return unless attachments.exists?

    message_ids = attachments.select(:MessageID)
    messages = Message.where(MessageID: message_ids)

    message_table = Message.arel_table
    participant_condition = message_table[:SenderID].eq(@user[:UserID])
                             .or(message_table[:recipientID].eq(@user[:UserID]))

    messages.where(participant_condition).exists? ? file : nil
  end

  def next_filedraft_pk_value
    pk = FileDraft.primary_key
    return [ nil, nil ] if pk.blank?

    col = FileDraft.columns_hash[pk]
    if col && [ :integer, :bigint ].include?(col.type)
      next_val = (FileDraft.maximum(pk) || 0) + 1
      [ pk, next_val ]
    else
      [ nil, nil ]
    end
  end

  def next_file_draft_id
    (FileDraft.maximum("ID") || 0) + 1
  end

  def set_conversation_context
    conv_id = params[:conversation_id].presence || params[:id]
    return unless conv_id

    @conversation = ::MessageString.find_by(ConversationID: conv_id) rescue nil
    @pmg          = ::PrimaryMessageGroup.find_by(ConversationID: conv_id) rescue nil

    @landlord = ::User.find_by(UserID: @pmg&.LandlordID)
    @tenant   = ::User.find_by(UserID: @pmg&.TenantID)
    @intake   = ::IntakeQuestion.find_by(IntakeID: @pmg&.IntakeID)
  end

  def require_login
    redirect_to login_path, alert: "You must be logged in." unless session[:user_id]
  end

  def set_user
    @user = ::User.find_by(UserID: session[:user_id])
    redirect_to login_path, alert: "Please log in." unless @user
  end
end
