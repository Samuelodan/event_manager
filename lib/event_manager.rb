# frozen_string_literal: false

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

puts 'Event Manager Initialized'

def clean_zipcode(zip)
  zip.to_s.rjust(5, '0')[0...5]
end

def legislators_by_zip(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zip = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zip(zip)
  begin
    personal_letter = template_letter.gsub('FIRST_NAME', name)
    personal_letter.gsub!('LEGISLATORS', legislators)
  rescue
    'no legislators found'
  end
  puts personal_letter

  # puts "#{name}\t#{zip}\t#{legislators}"
end
