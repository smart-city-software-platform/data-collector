class CreateData < ActiveRecord::Migration[5.0]
  def change
    create_table :data do |t|
      t.string :component_uuid
      t.float :lat
      t.float :lon
      t.string :capability
      t.string :attribute
      t.float :type
      t.string :unity
      t.text :value

      t.timestamps
    end
  end
end
