class ChangeResourceIdToResourceUuidAndTypeToStringFromEvents < ActiveRecord::Migration[5.0]
  
  def change  
    if column_exists? :events, :resource_id
      rename_column :events, :resource_id, :resource_uuid
      change_column :events, :resource_uuid, :string
    end
  end
end
