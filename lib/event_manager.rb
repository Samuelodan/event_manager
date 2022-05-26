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
form_letter = erb_template.result(binding)

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zip = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zip(zip)

  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end

  puts "#{name}\t#{zip}"
end
