function events(results) {
    const events = results["events"]
    const title = results["title"]

    var html = `<table class="section">`
    html += `<tbody><tr><td><table>`

    events.forEach(function (event, index) {
        html += `<td><table class="event" >`
        html += `<tr><td>${event.title}</td></tr>`
        html += `<tr><td>${event.datetime}</td></tr>`
        html += `<tr><td>${event.about}</td></tr>`
        html += `</table></td>`
    })

    html += `</table></td></tr></tbody>`
    html += `<tfoot><tr><td colspan="3">`
    html += `<a class="more" href="google.com">View More Events >></a>`
    html += `</td></tr></tfoot>`
    html += `</table>`
    return html
}
