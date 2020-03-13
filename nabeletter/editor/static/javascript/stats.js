function stats(result) {
    const title = result["title"]
    const images = result["images"]

    html = `<table class="section"><tr>`

    images.forEach(function (element, index) {
        html += `<td><img src="${element.url}"></td>`

        if (index % 2) {
            html += '</tr><tr>'
        }
    })

    html += `</tr></table>`

    return html
}
