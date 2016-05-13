class AddEventToDetail < ActiveRecord::Migration[5.0]
  def change
    add_reference :details, :event, foreign_key: true
  end
end
