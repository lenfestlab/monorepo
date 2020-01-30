from icalendar import Calendar
import requests
import arrow

import icalendar
import recurring_ical_events
import urllib.request
import datetime

def fetch():

  results = []
  
  url = "https://ics.teamup.com/feed/ks37xo2ni1ai6nmu88/4596912.ics"
  
  start_date = datetime.date.today()
  end_date = start_date + datetime.timedelta(days=7)

  ical_string = urllib.request.urlopen(url).read()
  calendar = icalendar.Calendar.from_ical(ical_string)
  events = recurring_ical_events.of(calendar).between(start_date, end_date)
  for element in events:
      event = {}
      dtstart = element.get("DTSTART",None)
      dtend = element.get("DTEND",None)      
      summary = element.get("SUMMARY",None)  
      description = element.get("DESCRIPTION",None)          
      
      if description is not None:
        description = (description[:175] + '...') if len(description) > 75 else description
      
      event['datetime'] = dtstart.dt
      event['begin'] = dtstart.dt
      event['end'] = dtend.dt
      event['title'] = summary
      event['about'] = description 
      event['source'] = url
      
      results.append(event)

    
  return results
