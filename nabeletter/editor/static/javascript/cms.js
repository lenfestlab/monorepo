var articles = []
var events = []
var tweets = []
var reviews = []
var permits = []
var headlines = []
var weatherData = {}
var safetyImages = []
var historyImages = []
var statsImages = []

function save() {
  parent.save(jsonResults())
}

function removeImage(e, id, images, removeFunction) {
  var replaceString = 'delete-' + id + '-'
  var index = parseInt(e.id.replace(replaceString,''));
  var image = images[index]
  var public_id = image['public_id']
  
  const successHandler = function(response) {
    images.splice(index,1);
    updateImages(id, images, removeFunction);
  }
  destroyImage(public_id, successHandler)  
}

function removeStatsImage(e) {
  var removeFunction = "removeStatsImage(this)"  
  removeImage(e, 'stats', statsImages, removeFunction)
}

function removeSafetyImage(e) {
  var removeFunction = "removeSafetyImage(this)"
  removeImage(e, 'safety', safetyImages, removeFunction)
}

function removeHistoryImage(e) {
  var removeFunction = "removeHistoryImage(this)"
  removeImage(e, 'history', historyImages, removeFunction)
}

function addSafetyImage(file) {  
  var removeFunction = "removeSafetyImage(this)"
  addImage(file, "safety", safetyImages, removeFunction, width=160, height=160) 
}

function addStatsImage(file) {  
  var removeFunction = "removeStatsImage(this)"  
  addImage(file, "stats", statsImages, removeFunction, width=160, height=160) 
}

function addHistoryImage(file) {
  var removeFunction = "removeHistoryImage(this)"
  addImage(file, "history", historyImages, removeFunction, width=263, height=160) 
}

function addImage(file, id, images, removeFunction, width, height) {
  const successHandler = function(response) {
    images.push(response);
    updateImages(id, images, removeFunction);
  }
  uploadImage(file, successHandler, width=width, height=height)
}

function updateHistoryImages() {
  updateImages("history", historyImages, "removeHistoryImage(this)");
}

function updateSafetyImages() {
  updateImages("safety", safetyImages, "removeSafetyImage(this)");
}

function updateStatsImages() {
  updateImages("stats", statsImages, "removeStatsImage(this)");
}

function updateImages(id, images, removeFunction) {
  var  html = "<table><tr>" 
  images.forEach(function (image, index) {
     html += `<td><div class="img-wrap">`
     html += `<button type="button" id="delete-${id}-${index}" class="btn-close btn btn-danger btn-sm" onclick='${removeFunction}'>`
     html += `&times;</button></span><img src="${image.url}"></div></td>`
  });
  html += "</tr></table>"
  $(`.${id} #images`).html( html);
  parent.refresh(jsonResults());
}

$(document).ready(function () {
  
  d3.json("https://nabeletter.lenfestlab.org/editions/6.json").then(function(results) {
    data = results['data']
    attributes = data['attributes']
    body_data = JSON.parse(attributes['body_data'])
    body_data.forEach(function (data_item, index) {
      
      type = data_item['type']
      if (type == 'neighborhood') {
        text = data_item['text']
        $('#headlineTextArea').val(text)
      } else if (type == 'weather') {
        summary = data_item['summary']
        $('#weatherTextArea').val(summary)
      } else if (type == 'news') {
        articles = data_item['articles']            
        articles.forEach(function (article, index) {
            article.selected = true
        });
      } else if (type == 'safety') {
        console.log(data_item)
        caption = data_item['caption']
        safetyImages = data_item['images'];
        updateSafetyImages()
        $('#safetyTextArea').val(caption)
      } else if (type == 'history') {
        console.log(data_item)
        caption = data_item['caption']
        historyImages = data_item['images'];
        updateHistoryImages()
        $('#historyTextArea').val(caption)
      } else if (type == 'stats') {
        console.log(data_item)
        statsImages = data_item['images'];
        updateStatsImages()
      } else if (type == 'tweets') {
        tweets = data_item['data']            
        tweets.forEach(function (tweet, index) {
            tweet.selected = true
        });
      } else if (type == 'permits') {
        permits = data_item['permits']            
        permits.forEach(function (permit, index) {
            permit.selected = true
        });
      } else if (type == 'reviews') {        
        reviews = data_item['data']            
        reviews.forEach(function (review, index) {
            review.selected = true
        });
      } else {
        console.log(data_item)
      }
    });

    loadData()

  });
  
})

function loadData() {
  
      d3.json("datasource/articles.json").then(function(results) {
        articles = articles.concat(results);
        articles.forEach(function (article, index) {
            var published = new Date(article.published)
            var option = document.createElement("option");
            option.text = `${published.toLocaleDateString("en-US")} - ${article.source} - ${article.title}, ${article.caption}`;
            option.value = index;
            if (article.selected) {
              $(".news #rightValues").append(option);
            } else {
              $(".news #leftValues").append(option);              
            }
        });
        
        parent.refresh(jsonResults());
      });
      
      d3.json("datasource/events.json").then(function(results) {
        events = events.concat(results);        
        events.forEach(function (event, index) {
            var option = document.createElement("option");
            option.text = `${event.datetime} - ${event.title}, ${event.about}`;
            option.value = index;
            if (event.selected) {
              $(".events #rightValues").append(option);
            } else {
              $(".events #leftValues").append(option);              
            }
        });
        
        parent.refresh(jsonResults());
      });
  
      d3.json("datasource/reviews.json").then(function(results) {
        reviews = reviews.concat(results);        
        reviews.forEach(function (review, index) {
            var date = new Date(review.date.datetime)
            var option = document.createElement("option");
            option.text = `${date.toLocaleDateString("en-US")} - ${review.title}, ${review.caption}`;
            option.value = index;
            if (review.selected) {
              $(".reviews #rightValues").append(option);
            } else {
              $(".reviews #leftValues").append(option);              
            }
        });
        
        parent.refresh(jsonResults());
      });
      
      d3.json("datasource/weather.json").then(function(results) {
        weather = results
        weatherData = weather['data']
        $('#weatherTextArea')[0].value = weather['summary'];
        
        parent.refresh(jsonResults());
      });
  
      d3.json("datasource/permits.json").then(function(results) {
        permits = permits.concat(results);        
        permits.forEach(function (permit, index) {
          var option = document.createElement("option");
            option.text = `${permit.type} - ${permit.address}, ${permit.description}`;
            option.value = index;
            if (permit.selected) {
              $(".permits #rightValues").append(option);
            } else {
              $(".permits #leftValues").append(option);              
            }
        });
        
        parent.refresh(jsonResults());
      });
  
      d3.json("datasource/tweets.json").then(function(results) {
        tweets = tweets.concat(results);        
        tweets.forEach(function (tweet, index) {
            var option = document.createElement("option");
            option.text = `${tweet.user.screen_name} - ${tweet.text}`;
            option.value = index;
            if (tweet.selected) {
              $(".tweets #rightValues").append(option);
            } else {
              $(".tweets #leftValues").append(option);              
            }
        });
        
        parent.refresh(jsonResults());
      });    

    addListboxObserver(".news")
    addListboxObserver(".events")
    addListboxObserver(".reviews")
    addListboxObserver(".permits")
    addListboxObserver(".tweets")

    addTextAreaObserver('#weatherTextArea');
    addTextAreaObserver('#headlineTextArea');
    addTextAreaObserver('#historyTextArea');
    addTextAreaObserver('#safetyTextArea');
    
    addFileUploadObserver('.history', addHistoryImage);
    addFileUploadObserver('.safety', addSafetyImage);
    addFileUploadObserver('.stats', addStatsImage);
}

function addFileUploadObserver(className, addFunction) {
  
  var field = $(className + ' #inputGroupFile')
  var label = $(className + " label[for='input']")
  var button = $(className + ' button')
  field.on('change', function () {
    var file = field.prop('files')[0];
    label.text(file.name);
  });
  button.click(function () {
    var files = field.prop('files');
    if (files.length > 0) {
      var file = files[0];
      addFunction(file)
    }
  });
}


function jsonResults() {
    results = []

    let selectedArticles = $(`.news #rightValues >option`).map(function () {
        let index = parseInt($(this).val())
        return articles[index];
    }).toArray();
    let selectedEvents = $(`.events #rightValues >option`).map(function () {
        let index = parseInt($(this).val())
        return events[index];
    }).toArray();
    let selectedPermits = $(`.permits #rightValues >option`).map(function () {
        let index = parseInt($(this).val())
        return permits[index];
    }).toArray();
    let selectedTweets = $(`.tweets #rightValues >option`).map(function () {
        let index = parseInt($(this).val())
        return tweets[index];
    }).toArray();
    let selectedReviews = $(`.reviews #rightValues >option`).map(function () {
        let index = parseInt($(this).val())
        return reviews[index];
    }).toArray();
    let selectedHeadlines = []

    headlineSummary = $('#headlineTextArea')[0].value
    if (headlineSummary.length > 0) {
        results.push({
          "type": "neighborhood",
          "title": "Summary of Neighborhood Headlines",
          "text": headlineSummary
  });
    }

    if (weatherData.length > 0) {
        results.push({
            "type": "weather",
            "title": "Weather Outlook",
            "data": weatherData,
            "summary": $('#weatherTextArea')[0].value
        });
    }

    if (selectedArticles.length > 0) {
        results.push({
            "type": "news",
            "title": "Fishtown News",
            "articles": selectedArticles
        });
    }

    if (selectedEvents.length > 0) {
        results.push({
            "type": "events",
            "title": "Fishtown Events",
            "events": selectedEvents
        });
    }

    safetyText = $('#safetyTextArea')[0].value
    results.push({
        "type": "safety",
        "title": "Fishtown Safety Watch",
        "images": safetyImages,
        "caption": safetyText
    });

    historyText = $('#historyTextArea')[0].value
    results.push({
        "type": "history",
        "title": "Fishtown History",
        "images": historyImages,
        "caption": historyText
    })
    
    results.push({
        "type": "stats",
        "title": "Fishtown Stats",
        "images": statsImages,
    })
    
    if (selectedTweets.length > 0) {
        results.push({
            "type": "tweets",
            "title": "Tweets from Local Officials",
            "data": selectedTweets
        });
    }
    
    if (selectedPermits.length > 0) {
        results.push({
            "type": "permits",
            "title": "New Construction & Demolition",
            "permits": selectedPermits
        });
    }
    
    
    if (selectedReviews.length > 0) {
        results.push({
            "type": "reviews",
            "title": "Permits Under Review",
            "data": selectedReviews
        });
    }

    return results;
}

function addTextAreaObserver(className) {
  const typeHandler = function(e) {
    parent.refresh(jsonResults());
  }
  weatherTextArea = $(className)[0]
  weatherTextArea.addEventListener('input', typeHandler) // register for oninput
  weatherTextArea.addEventListener('propertychange', typeHandler) 
}

function addListboxObserver(className) {
    $(`${className} #btnLeft`).click(function () {
        var selectedItem = $(`${className} #rightValues option:selected`);
        $(`${className} #leftValues`).append(selectedItem);
        parent.refresh(jsonResults());
    });

    $(`${className} #btnRight`).click(function () {
        var selectedItem = $(`${className} #leftValues option:selected`);
        $(`${className} #rightValues`).append(selectedItem);
        parent.refresh(jsonResults());
    });

    $(`${className} #rightValues`).change(function () {
        var selectedItem = $(`${className} #rightValues option:selected`);
        $(`${className} #txtRight`).val(selectedItem.text());
    });
}
