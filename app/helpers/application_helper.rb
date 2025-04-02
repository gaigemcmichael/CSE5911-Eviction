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
end
