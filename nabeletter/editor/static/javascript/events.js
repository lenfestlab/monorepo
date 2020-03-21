function events(results) {
    const events = results["events"]
    const title = results["title"]

  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content-47">`;
  
    var html = `<table>`
    html += `<tbody><tr><td><table>`

    events.forEach(function (event, index) {
        html += `<tr><td><table class="event" >`
        html += `<tr><td>${event.title}</td></tr>`
        html += `<tr><td>${event.datetime}</td></tr>`
        html += `<tr><td>${event.about}</td></tr>`
        html += `</table></td></tr>`
    })

    html += `</table>`

    html += `</td></tr></tbody>`
    
    html += `<tfoot><tr height=40><td>`
    html += `<a class="more" href="google.com">View More Events >></a>`
    html += `</td></tr></tfoot>`
    
    html += `</table>`
    content += html;
    content += `</td></tr></table>`;
    return content
}
