from .arc import *
from .star_news_philly import *
from .fishtown_org import *
from .streetdept import *

def fetch(key):
  results = []
  
  results.extend(streetdept.fetch())
  # results.extend(fishtown_org.fetch())
  results.extend(arc.fetch(key))
  results.extend(star_news_philly.fetch())
  return results