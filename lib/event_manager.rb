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

def save_thanks_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone)
  number = phone.gsub(/\D/, '')
  return number if number.length == 10
  return number.delete_prefix!('1') if number.length == 11 && number.start_with?('1')
  return 'bad number' if number.length.between?(0, 20)
end

def create_time(reg)
  date = reg.split(' ')[0].split('/')
  date[2] = date[2].rjust(4, '20')
  date = date.map(&:to_i)
  time = reg.split(' ')[-1].split(':').map(&:to_i)
  Time.new(date[2], date[0], date[1], time[0], time[1])
end

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zip = clean_zipcode(row[:zipcode])
  phone = row[:homephone]
  date = row[:regdate]

  legislators = legislators_by_zip(zip)

  form_letter = erb_template.result(binding)
  save_thanks_letter(id, form_letter)

  puts "#{name}\t#{zip}\t#{date}"
end
