require 'icalendar'
require 'nokogiri'
require 'open-uri'

include Icalendar

url = 'http://www.kaagent.be/wedstrijdkalender'
doc = Nokogiri::HTML open(url)
days = 60 * 60 * 24

calendar = Calendar.new

doc.css('.datatable ul li table tr').each_with_index do |tr, i|
  from = tr.css('td')[1].content.strip
  to = tr.css('td')[3].content.strip
  date_time = Time.parse tr.css('td')[5].content.gsub(/u/, ':')

  uid_date = if (1..5).include?(date_time.wday)
    date_time - ((date_time.wday - 1) * days) # monday of that week
  else # 6 & 0 => weekend
    date_time.wday == 0 ? (date_time - (1 * days)) : date_time # saturday of that week
  end
  uid = "#{from[0]}#{to[0]}#{(1..5).include?(date_time.wday) ? 'W' : 'WE'}#{uid_date.strftime('%Y%m%d')}"

  calendar.event do
    uid uid
    dtstart date_time.to_datetime
    dtend (date_time + (2 * 60 * 60)).to_datetime
    summary "#{from} - #{to}"
    location from
  end
end

file = File.new 'calendar.ics', 'w'
file.write calendar.to_ical
file.close
