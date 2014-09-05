# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'

puts "Truncating tables: events"
ActiveRecord::Base.connection.execute("TRUNCATE TABLE events")

seed_f = 'db/events_seeds.csv'
puts "CREATING EVENTS from #{seed_f}"
csv = CSV.open(seed_f, skip_blanks: true, col_sep: '|')
csv.each do |name, date, time, place|
  if date && time && place
    Event.find_or_create_by(name: name) do |event|
      event.date = (date.gsub!(/[^\d\.]/, '') + "2014 #{time}").to_datetime
      event.place = place
    end
    puts "created event: #{name}"
  end
end