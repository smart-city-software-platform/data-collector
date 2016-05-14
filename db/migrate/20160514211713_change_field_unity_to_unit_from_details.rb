class ChangeFieldUnityToUnitFromDetails < ActiveRecord::Migration[5.0]
  def change
  	if column_exists? :details, :unity
  	  rename_column :details, :unity, :unit
    end
  end
end
