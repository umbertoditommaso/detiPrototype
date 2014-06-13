class CreateVirtualChannels < ActiveRecord::Migration
  def change
    create_table :virtual_channels do |t|
      t.integer :channel
      t.integer :telemetry_id
      t.timestamps
    end
  end
end
