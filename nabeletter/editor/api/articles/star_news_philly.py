import feedparser
from bs4 import BeautifulSoup
import arrow

def fetch():
  d = feedparser.parse('https://starnewsphilly.com/feed/')
  
  articles = []

  entries = d.get("entries",{})
  for entry in entries:
    # description = entry.get("description",{})
    article = {}
    
    published = entry.get("published","")
    published = arrow.get(published, 'ddd, DD MMM YYYY HH:mm:ss +0000')
    article['published'] = str(published)
    
    basic_description = ""
    summary = entry.get("summary","")
    soup = BeautifulSoup(summary)
    ps = soup.findAll('p')
    if len(ps) > 0:
      basic_description = ps[0].text
        
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
        srcs = [x.split(' ') for x in lead['srcset'].split(', ')]
        for src in srcs:     
          if len(src) == 2 and src[1] == "300w":
            image = src[0]
    # if basic_promo_item_type == "image":
    #   additional_properties = basic_promo_item.get("additional_properties",{})
    #   image = additional_properties.get("thumbnailResizeUrl",None)
    #
    # source_url = None
    source_url = entry.get("link",None)
    # if canonical_url is not None:
    #   source_url = "https://www.inquirer.com" + canonical_url
    
    article['source'] = "Star News Philly"
    article['image'] = image
    article['title'] = basic_headline
    article['url'] = source_url
    article['caption'] = basic_description
    articles.append(article)
  
  return articles