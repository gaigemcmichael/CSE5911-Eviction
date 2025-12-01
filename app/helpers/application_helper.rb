module ApplicationHelper
  def needs_good_faith_response?(mediation, user)
    return false if mediation.deleted_at.nil?

    if user.Role == "Tenant"
      mediation.EndOfConversationGoodFaithLandlord.nil?
    elsif user.Role == "Landlord"
      mediation.EndOfConversationGoodFaithTenant.nil?
    else
      false
    end
  end

  # Return "active" when the current request path starts with the given
  # navigation path. This marks parent/nav links as active for detail pages
  # (for example: /messages and /messages/1 both match '/messages').
  # Special case: /mediation_summary, /good_faith_response, and /mediations are treated as
  # part of /messages navigation since they're message/mediation workflows.
  def active_nav_class(path)
    if path == "/messages"
      # Messages link is active for /messages, /mediations, /mediation_summary, /good_faith_response, and /intake_questions
      (request.path.start_with?("/messages") ||
       request.path.start_with?("/mediations") ||
       request.path.start_with?("/mediation_summary") ||
       request.path.start_with?("/good_faith_response") ||
       request.path.start_with?("/intake_questions")) ? "active" : ""
    elsif path == "/admin/mediations"
      # Admin Mediations link is active for /admin/mediations and /mediation_summary
      (request.path.start_with?("/admin/mediations") ||
       request.path.start_with?("/mediation_summary")) ? "active" : ""
    else
      request.path.start_with?(path) ? "active" : ""
    end
  end
end
