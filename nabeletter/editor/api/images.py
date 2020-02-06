import cloudinary
import cloudinary.uploader
import cloudinary.api

def upload(file, width, height):  
  # results = cloudinary.uploader.upload("https://picsum.photos/160/160")
  results = cloudinary.uploader.upload(file, width=width, height=height, crop="pad")
  print(results)
  # results = { "image": "https://picsum.photos/160/160" }
  return results
  
def destroy(public_id):  
  results = cloudinary.uploader.destroy(public_id)
  print(results)
  # results = { "image": "https://picsum.photos/160/160" }
  return results