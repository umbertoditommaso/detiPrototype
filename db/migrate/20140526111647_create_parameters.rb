class CreateParameters < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.string :name
      t.integer :telemetry_id

      t.timestamps
    end
  end
end
