class RemoveRequiresMediatorReviewFromMessages < ActiveRecord::Migration[8.0]
  def change
    remove_column "Messages", :RequiresMediatorReview, :boolean
  end
end
