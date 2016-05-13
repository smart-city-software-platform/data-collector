class RemoveFieldAttributeFromData < ActiveRecord::Migration[5.0]
  def change
    remove_column :data, :attribute, :string
  end
end
