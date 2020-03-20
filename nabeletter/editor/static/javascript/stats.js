function stats(result) {
    const title = result["title"]
    const images = result["images"]

  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content">`;
  
    html = `<table><tr>`

    images.forEach(function (element, index) {
        html += `<td><img src="${element.url}"></td>`

        if (index % 2) {
            html += '</tr><tr>'
        }
    })

    html += `</tr></table>`

    content += html;
    content += `</td></tr></table>`;
    return content
}
