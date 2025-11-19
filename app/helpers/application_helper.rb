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
  def active_nav_class(path)
    request.path.start_with?(path) ? "active" : ""
  end
end
