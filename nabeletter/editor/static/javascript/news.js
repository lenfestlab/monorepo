function news(results) {
    const articles = results["articles"]
    const title = results["title"]

    content = `<table class="section">`;
    content += `<tr><td class="title">${title}</td></tr>`;
    content += `<tr><td class="content-28">`;
  
    var html = `
    <table>
    <tbody><tr>`

    articles.forEach(function (article, index) {
        var published = new Date(article.published)
      
        html += `<td>`
        html += `<a target="_blank" href="${article.url}">`
      
        html += `<table class="article">`
        html += `<tr><td><img src="${article.image}" ><td></tr>`
        html += `<tr><td class="text-style-1">${article.title}<td></tr>`
        html += `<tr><td class="text-style-2">${published.toLocaleDateString("en-US")}<td></tr>`
        html += `<tr><td class="text-style-0">${article.caption}<td></tr>`
        html += `<tr><td class="text-style-3"><b>${article.source}</b><td></tr>`
        html += `</table>`
        html += `</a>`
        html += `</td>`

        if (index % 2) {
            html += '</tr><tr>'
        }
    })

    html += '</tr></tbody></table>'
    content += html;
    content += `</td></tr></table>`;
    return content
}
