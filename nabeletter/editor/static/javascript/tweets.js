function tweets(results) {
    const tweets = results["data"]
    const title = results["title"]

  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content-28">`;
  
    var html = `<table>`
    html += `<tbody><tr><td><table>`

    width = 100/tweets.length
    tweets.forEach(function (tweet, index) {
        html += `<td width="${width}%"><a target="_blank" href="${tweet.url}">`
        html += `<table class="tweet">`
        html += `<tr><td><b>${tweet.user.name}</b></td></tr>`
        html += `<tr><td>${tweet.html}</td></tr>`
        html += `</table>`
        html += `</a></td>`
    })

    html += `</table></td></tr></tbody>`
    html += `</table>`
    content += html;
    content += `</td></tr></table>`;
    return content
}
