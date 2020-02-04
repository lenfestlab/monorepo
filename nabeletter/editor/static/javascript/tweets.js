function tweets(results) {
    const tweets = results["data"]
    const title = results["title"]

    var html = `<table class="section">`
    html += `<tbody><tr><td><table>`

    width = 100/tweets.length
    tweets.forEach(function (tweet, index) {
        html += `<td width="${width}%"><a target="_blank" href="${tweet.url}"><table class="tweet" >`
        html += `<tr><td><b>${tweet.user.name}</b></td></tr>`
        html += `<tr><td>${tweet.html}</td></tr>`
        html += `</table></a></td>`
    })

    html += `</table></td></tr></tbody>`
    html += `</table>`
    return html
}
