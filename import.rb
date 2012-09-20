require 'nokogiri'
require 'open-uri'

url = 'http://www.kaagent.be/wedstrijdkalender'
doc = Nokogiri::HTML open(url)

`echo "BEGIN:VCALENDAR
X-WR-TIMEZONE:Europe/Brussels
CALSCALE:GREGORIAN
VERSION:2.0" > calendar.ics`

doc.css('.datatable ul li table tr').each_with_index do |tr, i|
  from = tr.css('td')[1].content.strip
  to = tr.css('td')[3].content.strip
  date_time = Time.parse tr.css('td')[5].content.gsub(/u/, ':')

  # start_time - 2 hours because of our GMT+2 zone (gmt+2 because of summer time)
  start_string = (date_time - (2 * 60 * 60)).strftime('%Y%m%dT%H%M%SZ')
  end_string = date_time.strftime('%Y%m%dT%H%M%SZ')

`echo "BEGIN:VEVENT
DTSTART;VALUE=DATE-TIME:#{start_string}
DTEND;VALUE=DATE-TIME:#{end_string}
SUMMARY:#{from} - #{to}
LOCATION:#{from}
END:VEVENT" >> calendar.ics`
end

`echo "END:VCALENDAR" >> calendar.ics`
