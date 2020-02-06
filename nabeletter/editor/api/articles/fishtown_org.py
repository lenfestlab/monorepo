import feedparser
from bs4 import BeautifulSoup

def fetch():
  d = feedparser.parse('https://www.fishtown.org/news/feed')
  
  articles = []

  entries = d.get("entries",{})
  for entry in entries:
    article = {}
    # description = entry.get("description",{})
    basic_description = ""
    published = entry.get("published","")
    article['published'] = published
    
    summary = entry.get("summary","")
    basic_description = summary

        
    #
    # headlines = entry.get("headlines",{})
    basic_headline = entry.get("title","")
    #
    # promo_items = entry.get("promo_items",{})
    # basic_promo_item = promo_items.get("basic",{})
    image = None
    content = entry.get("content",[])
    for element in content:
      value = element.get("value",None)
      soup = BeautifulSoup(value)
      images = soup.findAll('img')
      if len(images) > 0:
        lead = images[0]
        image = str(lead['src'])
        # srcs = [x.split(' ') for x in lead['srcset'].split(', ')]
        # for src in srcs:
        #   if len(src) == 2 and src[1] == "300w":
        #     image = src[0]
    # if basic_promo_item_type == "image":
    #   additional_properties = basic_promo_item.get("additional_properties",{})
    #   image = additional_properties.get("thumbnailResizeUrl",None)
    #
    # source_url = None
    source_url = entry.get("link",None)
    # if canonical_url is not None:
    #   source_url = "https://www.inquirer.com" + canonical_url
    
    article['source'] = "Fishtown.org"
    article['image'] = image
    article['title'] = basic_headline
    article['url'] = source_url
    article['caption'] = basic_description
    articles.append(article)
  
  return articles