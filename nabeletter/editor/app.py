from flask import Flask, render_template, jsonify
import os
import api

from dotenv import load_dotenv

load_dotenv('.env')

app = Flask(__name__, static_url_path='')

app.config.from_pyfile('settings.py')
        
@app.route("/new", methods=['GET'])
def create():
  return render_template('interactive.html')
  
@app.route("/edition/<int:edition_id>/edit", methods=['GET'])
def new():
  return 'Edition %d' % edition_id
  return render_template('hello.html', name=edition_id)
  
@app.route("/index.html", methods=['GET'])
def index():
  return render_template('index.html')
  
@app.route("/cms.html", methods=['GET'])
def cms():
    return render_template('cms.html')  
  
@app.route("/datasource/permits.json", methods=['GET'])
def fetch_permits():
  results = api.permits.fetch()
  return jsonify(results)
    
@app.route("/datasource/articles.json", methods=['GET'])
def fetch_articles():
  results = api.articles.fetch(app.config.get("ARC_API_KEY"))
  return jsonify(results)
  
@app.route("/datasource/events.json", methods=['GET'])
def fetch_events():
  results = api.events.fetch()
  return jsonify(results)  
  
@app.route("/datasource/weather.json", methods=['GET'])
def fetch_weather():
  results = api.weather.fetch(app.config.get("DARKSKY_API_KEY"))
  return jsonify(results)
  
@app.route("/datasource/tweets.json", methods=['GET'])
def fetch_tweets():
  results = api.tweets.fetch(app.config.get("TWITTER_API_KEY"), app.config.get("TWITTER_API_SECRET"))
  return jsonify(results)
  
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 9000))
    app.run(host='0.0.0.0', port=port)
