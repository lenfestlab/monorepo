from flask import Flask, render_template, jsonify, request
import os
import api
import cloudinary.api
from werkzeug.utils import secure_filename

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

from dotenv import load_dotenv

load_dotenv('.env')

app = Flask(__name__, static_url_path='')

app.config.from_pyfile('settings.py')

cloudinary.config( 
  cloud_name = app.config.get("CLOUDINARY_NAME"),
  api_key = app.config.get("CLOUDINARY_API_KEY"), 
  api_secret = app.config.get("CLOUDINARY_API_SECRET") 
)
   
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS   
     
@app.route("/new", methods=['GET'])
def create():
  return render_template('interactive.html')
  
@app.route("/editions/<int:edition_id>", methods=['GET'])
def edit(edition_id):
  # return 'Edition %d' % edition_id
  return render_template('interactive.html', edition_id=edition_id)
  
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
  
@app.route("/datasource/reviews.json", methods=['GET'])
def fetch_reviews():
  results = api.reviews.fetch()
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
  
@app.route("/images/upload.json", methods=['POST'])
def uploadImage():
  results = { "error": 'Unknown error' }, 422
  # check if the post request has the file part
  if 'file' not in request.files:
      return { "error": 'No file part' }, 422
      
  file = request.files['file']
  # if user does not select file, browser also
  # submit an empty part without filename
  if file.filename == '':
      return { "error": 'No file part' }, 422
  
  if not allowed_file(file.filename):
      return { "error": 'File not allowed' }, 422
      
  width = request.headers.get('width')    
  height = request.headers.get('height')
  
  if width == None:
      return { "error": 'Missing width' }, 422
  
  if height == None:
      return { "error": 'Missing height' }, 422
  
  if file:
      results = api.images.upload(file, width=width, height=height)
  
  return jsonify(results)
  
@app.route("/images/<public_id>.json", methods=['DELETE'])
def destroyImage(public_id):
  results = api.images.destroy(public_id)
  return jsonify(results)
  
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 9000))
    app.run(host='0.0.0.0', port=port)
