class CreateLocks < ActiveRecord::Migration
  def change
    create_table :locks do |t|
      t.string :resource
      t.string :mode,:limit => 1, :null => false
      t.integer :task_id

      t.timestamps
    end
  end
end
