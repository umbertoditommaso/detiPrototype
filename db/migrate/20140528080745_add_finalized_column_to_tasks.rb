class AddFinalizedColumnToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :finalized, :boolean
  end
end
