var articles = []
var events = []
var permits = []
var headlines = []
var weatherData = {}
var safetyImages = []
var historyImages = []

function uploadImage(file, success, error, width, height) {
  var form_data = new FormData();
  form_data.append('file', file);
  $.ajax({
        url: 'http://localhost:9000/images/upload.json', // point to server-side controller method
        headers: {
                'width': width,
                'height': height,
            },
        dataType: 'json', // what to expect back from the server
        cache: false,
        contentType: false,
        processData: false,
        data: form_data,
        type: 'post',
        success: success,
        error: error
    });
}

function destroyImage(public_id, success, error) {
  $.ajax({
        url: `http://localhost:9000/images/${public_id}.json`, // point to server-side controller method
        dataType: 'json', // what to expect back from the server
        cache: false,
        contentType: false,
        processData: false,
        type: 'delete',
        success: success,
        error: error
    });
}

function removeSafetyImage(e) {
  var index = parseInt(e.id.replace('delete-safety-',''));
  var image = safetyImages[index]
  var public_id = image['public_id']
  
  const successHandler = function(response) {
    safetyImages.splice(index,1);
    updateSafetyImages()
  }
  
  const errorHandler = function(response) {
    alert(response.responseJSON["error"])
  }

  destroyImage(public_id, successHandler, errorHandler)
}

function addSafetyImage(file) {  
  const successHandler = function(response) {
    safetyImages.push(response);
    updateSafetyImages()
  }
  
  const errorHandler = function(response) {
    alert(response.responseJSON["error"])
  }
  
  uploadImage(file, successHandler, errorHandler, width=160, height=160)
}

function removeHistoryImage(e) {
  var index = parseInt(e.id.replace('delete-history-',''));
  var image = historyImages[index]
  var public_id = image['public_id']
  
  const successHandler = function(response) {
    historyImages.splice(index,1);
    updateHistoryImages()
  }
  
  const errorHandler = function(response) {
    alert(response.responseJSON["error"])
  }

  destroyImage(public_id, successHandler, errorHandler)
}

function addHistoryImage(file) {  
  const successHandler = function(response) {
    historyImages.push(response);
    updateHistoryImages()
  }
  
  const errorHandler = function(response) {
    alert(response.responseJSON["error"])
  }
  
  uploadImage(file, successHandler, errorHandler, width=263, height=160)
}

function updateHistoryImages() {
  var safetyHTML = "<table><tr>"
    
  safetyHTML += ''
    
  historyImages.forEach(function (image, index) {
    safetyHTML += `<td><div class="img-wrap">`
    safetyHTML += `<button type="button" id="delete-history-${index}" class="btn-close btn btn-danger btn-sm" onclick='removeHistoryImage(this)'>`
    safetyHTML += `&times;`
    safetyHTML += `</button>`
    safetyHTML += `</span><img src="${image.url}">`
    safetyHTML += `</div></td>`
  });
  safetyHTML += ''
    
  safetyHTML += "</tr></table>"
  $(".history #images").html(safetyHTML);
  parent.refresh(jsonResults());
}

function updateSafetyImages() {
  var safetyHTML = "<table><tr>"
    
  safetyHTML += ''
    
  safetyImages.forEach(function (image, index) {
    safetyHTML += `<td><div class="img-wrap">`
    safetyHTML += `<button type="button" id="delete-safety-${index}" class="btn-close btn btn-danger btn-sm" onclick='removeSafetyImage(this)'>`
    safetyHTML += `&times;`
    safetyHTML += `</button>`
    safetyHTML += `</span><img src="${image.url}">`
    safetyHTML += `</div></td>`
  });
  safetyHTML += ''
    
  safetyHTML += "</tr></table>"
  $(".safety #images").html(safetyHTML);
  parent.refresh(jsonResults());

}

$(document).ready(function () {
  
    Promise.all([
      d3.json("datasource/articles.json"),
      d3.json("datasource/events.json"),
      d3.json("datasource/reviews.json"),
      d3.json("datasource/weather.json"),
      d3.json("datasource/permits.json"),
      d3.json("datasource/tweets.json")
    ]).then(function(results) {

        articles = results[0]
        articles.forEach(function (article, index) {
            var published = new Date(article.published)
            var option = document.createElement("option");
            option.text = `${published.toLocaleDateString("en-US")} - ${article.source} - ${article.title}, ${article.caption}`;
            option.value = index;
            $(".news #leftValues").append(option);
        });

        events = results[1]
        events.forEach(function (event, index) {
            var option = document.createElement("option");
            option.text = `Event #${index}: ${event.datetime} - ${event.title}, ${event.about}`;
            option.value = index;
            $(".events #leftValues").append(option);
        });

        reviews = results[2]
        reviews.forEach(function (review, index) {
            var date = new Date(review.date.datetime)
            var option = document.createElement("option");
            option.text = `${date.toLocaleDateString("en-US")} - ${review.title}, ${review.caption}`;
            option.value = index;
            $(".reviews #leftValues").append(option);
        });

        weather = results[3]
        weatherData = weather['data']
        $('#weatherTextArea')[0].value = weather['summary'];
        
        permits = results[4]
        permits.forEach(function (permit, index) {
            var option = document.createElement("option");
            option.text = `Permit #${index}: ${permit.type} - ${permit.address}, ${permit.description}`;
            option.value = index;
            $(".permits #leftValues").append(option);
        });
        
        tweets = results[5]
        tweets.forEach(function (tweet, index) {
            var option = document.createElement("option");
            option.text = `Tweet #${index}: ${tweet.user.screen_name} - ${tweet.text}`;
            option.value = index;
            $(".tweets #leftValues").append(option);
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
})

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