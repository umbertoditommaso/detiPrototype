class CreateTelemetries < ActiveRecord::Migration
  def change
    create_table :telemetries do |t|
      t.string :name
      t.integer :database_id
      t.timestamps
    end
  end
end
