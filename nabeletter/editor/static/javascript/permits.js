function permits(results) {
    const permits = results["permits"]
    const title = results["title"]

    var html = `
    <table class="section">
    <tbody><tr>`

    permits.forEach(function (permit, index) {
        html += `<td>`
      
        html += `<table class="permit">`
        html += `<tr><td><img src="${permit.image}" ><td>`
        html += `<td class="newstitle">`
        html += `<table>`
        html += `<tr><td>${permit.address} | ${permit.type} </td></tr>`
        html += `<tr><td>${permit.date}<td></tr>`
        html += `<tr><td class="newscaption">${permit.description}<td></tr>`
        html += `<tr><td>Property Owner: ${permit.property_owner}<td></tr>`
        html += `<tr><td>Contractor: ${permit.contractor_name}<td></tr>`
        html += `</table>`
        html += `</table>`
        html += `</td>`
        html += '</tr><tr>'
    })

    html += '</tr></tbody></table>'
    return html
}
