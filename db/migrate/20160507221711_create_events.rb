class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :type
      t.integer :resource_id
      t.datetime :date

      t.timestamps
    end
  end
end
