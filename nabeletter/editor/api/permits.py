import requests
import arrow

def fetch():

  url = """https://extry.herokuapp.com/odp/permits"""

  response = requests.request("GET", url)

  data = response.json()

  permits = []

  for element in data:
    people = element.get("people",[])
    property_owner = ""
    contractor_name = ""
    for person in people:
      person_name = person.get("name", "")
      person_title = person.get("title", "")
      if person_title == "Property Owner":
        property_owner = person_name
      elif person_title == "Contractor":
        contractor_name = person_name
            
    location = element.get("location",{})
    address = location.get("address","")
    description = element.get("description","")
    title = element.get("title","")
    date = element.get("date",{})
    date_name = date.get("name","")
    date_datetime = date.get("datetime","")
    datetime = arrow.get(date_datetime)
    date_formatted = datetime.format('MMMM DD, YYYY')
    tags = element.get("tags",[{}])
    permit_type = ""
    if len(tags) > 0:
      permit_type = tags[0].get("name","")
  #   basic_description = description.get("basic","")
  #
  #   headlines = element.get("headlines",{})
  #   basic_headline = headlines.get("basic","")
  #
  #   promo_items = element.get("promo_items",{})
  #   basic_promo_item = promo_items.get("basic",{})
  #   basic_promo_item_type = basic_promo_item.get("type","unknown")
  #   image = ""
  #   if basic_promo_item_type == "image":
  #     additional_properties = basic_promo_item.get("additional_properties",{})
  #     image = additional_properties.get("thumbnailResizeUrl",None)
  #
  #   source_url = None
  #   canonical_url = element.get("canonical_url",None)
  #   if canonical_url is not None:
  #     source_url = "https://www.inquirer.com" + canonical_url
  #
    image_dimensions = '400x300'
    permit = {}
    permit['address'] = title
    permit['image'] = "https://maps.googleapis.com/maps/api/streetview?key=AIzaSyA0zzOuoJnfsAJ1YIfPJ7RrtXeiYbdW-ZQ&size="+image_dimensions+"&location="+address
    permit['date'] = date_name + ": " + date_formatted
    permit['type'] = permit_type
    permit['property_owner'] = property_owner
    permit['contractor_name'] = contractor_name
    permit['description'] = description
    permits.append(permit)
  
  return permits
  