class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name_id
      t.string :exec
      t.string :arguments
      t.string :path
      t.text :settings
      t.timestamps
    end
  end
end
