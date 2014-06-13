class CreateDatabases < ActiveRecord::Migration
  def change
    create_table :databases do |t|
      t.string :version
      t.string :mission
      t.boolean :active
      t.timestamps
    end
  end
end
