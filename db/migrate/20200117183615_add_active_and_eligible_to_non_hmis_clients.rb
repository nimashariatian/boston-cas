class AddActiveAndEligibleToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :active_client, :boolean, null: false, default: true
    add_column :non_hmis_clients, :eligible_for_matching, :boolean, null: false, default: true
  end
end
