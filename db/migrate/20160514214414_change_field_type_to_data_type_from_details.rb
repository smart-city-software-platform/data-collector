class ChangeFieldTypeToDataTypeFromDetails < ActiveRecord::Migration[5.0]
  
  def change
  	if column_exists? :details, :type
  	  rename_column :details, :type, :data_type
    end
  end
end
