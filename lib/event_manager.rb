# frozen_string_literal: false

require 'csv'
require 'google/apis/civicinfo_v2'

puts 'Event Manager Initialized'

def clean_zipcode(zip)
  zip.to_s.rjust(5, '0')[0...5]
end

def legislators_by_zip(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials.map(&:name).join(', ')
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
  legislators
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zip = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zip(zip)

  puts "#{name}\t#{zip}\t#{legislators}"
end
