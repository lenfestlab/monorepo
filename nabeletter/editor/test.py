import icalendar
import recurring_ical_events
import urllib.request
import datetime

start_date = datetime.date.today()
end_date = start_date + datetime.timedelta(days=7)

url = "https://ics.teamup.com/feed/ks37xo2ni1ai6nmu88/4596912.ics"

ical_string = urllib.request.urlopen(url).read()
calendar = icalendar.Calendar.from_ical(ical_string)
events = recurring_ical_events.of(calendar).between(start_date, end_date)
for event in events:
    start = event["DTSTART"].dt
    duration = event["DTEND"].dt - event["DTSTART"].dt
    print("start {} duration {}".format(start, duration))