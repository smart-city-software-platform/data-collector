class CreateSensorValues < ActiveRecord::Migration[5.0]
  def change
    create_table :sensor_values do |t|
      t.string :value
      t.datetime :date

      t.timestamps
    end
  end
end
