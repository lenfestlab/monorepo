var articles = []
var events = []
var permits = []
var headlines = []
var weatherData = {}

$(document).ready(function () {

    Promise.all([
      d3.json("datasource/articles.json"),
      d3.json("datasource/events.json"),
      d3.json("datasource/headlines.json"),
      d3.json("datasource/weather.json"),
      d3.json("datasource/permits.json"),
      d3.json("datasource/tweets.json")
    ]).then(function(results) {
        articles = results[0]
        articles.forEach(function (article, index) {
            var option = document.createElement("option");
            option.text = `News Story #${index}: ${article.source} - ${article.title}, ${article.caption}`;
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

        headlines = results[2]
        headlines.forEach(function (headline, index) {
            var option = document.createElement("option");
            option.text = `Story #${index}: ${headline.source} - ${headline.title}, ${headline.caption}`;
            option.value = index;
            $(".headlines #leftValues").append(option);
        });

        weather = results[3]
        weatherData = weather['data']
        weatherSummary = weather['summary']
        document.getElementById('exampleFormControlTextarea1').value = weatherSummary;
        
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
    addListboxObserver(".headlines")
    addListboxObserver(".permits")
    addListboxObserver(".tweets")
})

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
    let selectedHeadlines = []

    if (weatherData.length > 0) {
        results.push({
            "type": "weather",
            "title": "Weather Outlook",
            "data": weatherData,
            "summary": "Light rain on Saturday through next Thursday."
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

    results.push({
        "type": "safety",
        "title": "Fishtown Safety Watch",
        "images": [
            {
                "image": "https://picsum.photos/160/160"
            },
            {
                "image": "https://picsum.photos/160/160"
            },
            {
                "image": "https://picsum.photos/160/160"
            }
        ],
        "caption": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut."
    });

    results.push({
        "type": "history",
        "title": "Fishtown History",
        "images": [
            {
                "image": "https://picsum.photos/263/160"
            },
            {
                "image": "https://picsum.photos/263/160"
            }
        ],
        "caption": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
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

    return results;
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
