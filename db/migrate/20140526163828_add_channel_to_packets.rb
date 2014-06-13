class AddChannelToPackets < ActiveRecord::Migration
  def change
    add_column :packets, :channel, :integer
  end
end
