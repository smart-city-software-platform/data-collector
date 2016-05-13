class RemoveFieldLatFromData < ActiveRecord::Migration[5.0]
  def change
    remove_column :data, :lat, :float
  end
end
