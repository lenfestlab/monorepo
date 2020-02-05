import tweepy
    
def entityFromTweet(tweet):
  entity = {}
  entity["text"] = tweet.full_text
  entity["id"] = tweet.id
  entity["url"] = "https://twitter.com/"+tweet.user.screen_name+"/status/"+tweet.id_str
  
  html = tweet.full_text
  entities = tweet.entities
  for url in entities.get("urls",[]):
    html = html.replace(url['url'], "<a href='"+url['url']+"'>"+url['display_url']+"</a>")
  if "urls" in entities:
    del entities["urls"]
  
  media = []
  for mediaEntity in entities.get("media",[]):
    sizes = mediaEntity.get("sizes",{})
    s = "thumb"
    size = sizes.get(s,{})
    h = size.get("h","")
    w = size.get("w","")
    media_url_https = mediaEntity.get("media_url_https","")
    sized_media_url_https = media_url_https+":"+s+"#"+str(w)+"X"+str(h)
    media.append(sized_media_url_https)
    html = html.replace(mediaEntity['url'], "<a href='"+mediaEntity['url']+"'><img src='"+sized_media_url_https+"'></a>")        
  if "media" in entities:
    del entities["media"]
    
  entities = tweet.entities
  increment = 0
  for hashtag in entities.get("hashtags",[]):
    indices = hashtag['indices']
    
    html = html[:indices[0]+increment]+"<b>"+html[indices[0]+increment:indices[1]+increment]+"</b>"+html[indices[1]+increment:]
    increment += 7
  if "hashtags" in entities:
    del entities["hashtags"]
          
  entity["html"] = html
  user = {}
  user["name"] = tweet.user.name
  user["screen_name"] = tweet.user.screen_name
  
  entity["user"] = user
  entity["entities"] = entities
  entity["media"] = media
  
  return entity
  
def fetch(consumer_key, consumer_secret):
  auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
  api = tweepy.API(auth)

  qs = []
  officials = ["CMMarkSquilla", "Darrell_Clarke", "venisew", "jongeeting"]
  q = 'from:'+"+OR+from:".join(officials) + "AND -filter:retweets AND -filter:replies"
  qs.append(q)
  officials = ["helengymatlarge","teamdomb"]
  q = 'fishtown from:'+"+OR+from:".join(officials) + "AND -filter:retweets AND -filter:replies"
  qs.append(q)
  print(qs)
  statuses = []
  for q in qs:
    for tweet in tweepy.Cursor(api.search, q=q, rpp=100, result_type="recent", tweet_mode="extended").items():
      entity = entityFromTweet(tweet)
      statuses.append(entity)
      
  return statuses