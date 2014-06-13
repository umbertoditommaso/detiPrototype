class CreatePackets < ActiveRecord::Migration
  def change
    create_table :packets do |t|
      t.string :spid
      t.integer :telemetry_id
      t.timestamps
    end
  end
end
