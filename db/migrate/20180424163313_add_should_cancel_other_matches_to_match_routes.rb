class AddShouldCancelOtherMatchesToMatchRoutes < ActiveRecord::Migration[4.2]
  def change
    add_column :match_routes, :should_cancel_other_matches, :boolean, default: true, null: false

    MatchRoutes::ProviderOnly.first.update(should_cancel_other_matches: false)
  end
end
