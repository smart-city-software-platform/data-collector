class RemoveFieldLonFromData < ActiveRecord::Migration[5.0]
  def change
    remove_column :data, :lon, :float
  end
end
