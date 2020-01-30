import requests

def fetch():

  url = """https://api.pmn.arcpublishing.com/content/v4/search/published/?sort=created_date:desc&size=10&body={
    \"_source\": {
      \"exclude\": [\"revision\", \"syndication\", \"taxonomy\", \"related_content\", \"publishing\", \"credits\", \"subheadlines\", \"source\", \"additional_properties\", \"workflow\", \"distributor\", \"planning\", \"websites\", \"language\", \"label\", \"owner\", \"content_elements\", \"address\", \"headlines.tablet\", \"headlines.mobile\", \"headlines.web\", \"headlines.native\", \"headlines.meta_title\", \"headlines.print\"]
    },
    \"query\": {
      \"bool\": {
        \"must\": [{
          \"match\": {
            \"type\": \"story\"
          }
        }, {
          \"match\": {
            \"content_elements.content\": \"Fishtown\"
          }
        }, {
          \"range\": {
            \"created_date\": {
              \"gte\": \"now-7d/d\",
              \"lt\": \"now/d\"
            }
          }
        }]
      }
    }
  }
  &website=philly-media-network&exclude_distributor_category=wires,other"""

  payload  = {}
  headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': 'Bearer HLGF71ANTGQM3A7U5TTVFPF8GBMVL4P2BrKy0LbKPNTS90etja6Z5CUKeFaHlxxLLcNdsHnI'
  }

  response = requests.request("GET", url, headers=headers, data = payload)

  data = response.json()

  articles = []

  content_elements = data['content_elements']
  for element in data['content_elements']:
    description = element.get("description",{})
    basic_description = description.get("basic","")
    
    headlines = element.get("headlines",{})
    basic_headline = headlines.get("basic","")
    
    promo_items = element.get("promo_items",{})
    basic_promo_item = promo_items.get("basic",{})
    basic_promo_item_type = basic_promo_item.get("type","unknown")
    image = ""
    if basic_promo_item_type == "image":
      additional_properties = basic_promo_item.get("additional_properties",{})
      image = additional_properties.get("thumbnailResizeUrl",None)
      
    source_url = None
    canonical_url = element.get("canonical_url",None)
    if canonical_url is not None:
      source_url = "https://www.inquirer.com" + canonical_url
    
    article = {}
    article['source'] = "Inquirer"
    article['image'] = image
    article['title'] = basic_headline
    article['url'] = source_url
    article['caption'] = basic_description
    articles.append(article)
  
  return articles
  