import requests
import datetime

def fetch(key):
  
  latitude = 39.9710
  longitude = -75.1285
    
  url = "https://api.darksky.net/forecast/{}/{},{}?exclude=currently,hourly,minutely,flags".format(key,latitude,longitude)
  print(url)
  response = requests.request("GET", url)

  results = response.json()
  daily = results.get("daily",{})
  data = daily.get("data",{})
  
  weather = {}
  
  days = []
  day = datetime.date.today()
  # for i in range(7) {}
  #   datetime.date.today().strftime("%a")
    
  for element in data:
    element['dayofweek'] = day.strftime("%a")
    day += datetime.timedelta(days=1)
    
  
  return daily