# frozen_string_literal: false

require 'csv'

puts 'Event Manager Initialized'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zip = row[:zipcode]

  if zip.nil?
    zip = '00000'
  elsif zip.length < 5
    zip = zip.rjust(5, '0')
  elsif zip.length > 5
    zip = zip[0...5]
  end

  puts "#{name}\t#{zip}"
end
