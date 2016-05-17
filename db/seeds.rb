# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#

p "Removing old events/details entries..."

Detail.delete_all
Event.delete_all

p "Creating new events..."

1000.times do |index|
  event = Event.create!(resource_id: Faker::Number.number(8),
                		date: Faker::Time.between(DateTime.now - 1, DateTime.now),
                		category: ["pull", "push"].sample)

  3.times do |j|
  	event.detail.create!(component_uuid: Faker::Code.ean, # a fake number
  				   capability: ["temperature", "pressure", "humidity", "luminosity", "manipulate_led"].sample,
  				   data_type: "double",
  				   unit: "none", # unit must be specific depending on the data type
  				   value: Faker::Number.decimal(2, 3)
  		)
  end
end

p "Created #{Event.count} events"
