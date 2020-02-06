function news(results) {
    const articles = results["articles"]
    const title = results["title"]

    var html = `
    <table class="section">
    <tbody><tr>`

    articles.forEach(function (article, index) {
        html += `<td>`
        html += `<a target="_blank" href="${article.url}">`
      
        html += `<table class="article">`
        html += `<tr><td><img src="${article.image}" ><td></tr>`
        html += `<tr><td class="newstitle">${article.title}<td></tr>`
        html += `<tr><td class="newscaption">${article.caption}<td></tr>`
        html += `<tr><td><b>${article.source}</b><td></tr>`
        html += `</table>`
        html += `</a>`
        html += `</td>`

        if (index % 2) {
            html += '</tr><tr>'
        }
    })

    html += '</tr></tbody></table>'
    return html
}
