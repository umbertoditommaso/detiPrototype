class AddPidToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :pid, :integer
  end
end
