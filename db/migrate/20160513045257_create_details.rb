class CreateDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :details do |t|
      t.string :component_uuid
      t.string :capability
      t.string :type
      t.string :unity
      t.text :value

      t.timestamps
    end
  end
end
