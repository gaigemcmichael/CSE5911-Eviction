class DocumentSignatureChannel < ApplicationCable::Channel
  def subscribed
    file = FileDraft.find_by(FileID: params[:file_id])
    if file
      stream_from "document_#{params[:file_id]}"
    else
      reject
    end
  end

  def unsubscribed
    
  end
end
