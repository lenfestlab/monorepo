import requests
import arrow

def fetch():

  url = """https://extry.herokuapp.com/fna/meetings"""

  response = requests.request("GET", url)

  data = response.json()
    
  return data
  