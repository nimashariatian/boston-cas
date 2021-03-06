class AddAssignedProgramPermissions < ActiveRecord::Migration[4.2]
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_view_assigned_programs, :boolean
    remove_column :roles, :can_edit_assigned_programs, :boolean
  end
end
