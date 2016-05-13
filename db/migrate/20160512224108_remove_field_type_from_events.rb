class RemoveFieldTypeFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :type, :string
  end
end
