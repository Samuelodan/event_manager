# frozen_string_literal: false

require 'csv'

puts 'Event Manager Initialized'

def clean_zipcode(zip)
  if zip.nil?
    '00000'
  elsif zip.length < 5
    zip.rjust(5, '0')
  elsif zip.length > 5
    zip[0...5]
  else
    zip
  end
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zip = row[:zipcode]

  puts "#{name}\t#{clean_zipcode(zip)}"
end
