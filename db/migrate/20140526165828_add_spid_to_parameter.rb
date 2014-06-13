class AddSpidToParameter < ActiveRecord::Migration
  def change
    add_column :parameters, :spid, :integer
  end
end
