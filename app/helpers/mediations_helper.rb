module MediationsHelper
  def good_faith_label(response)
    return "Pending" if response.nil?
    response ? "Yes" : "No"
  end
end
