function permits(results) {
    const permits = results["permits"]
    const title = results["title"]

  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content-47">`;
  
    var html = `
    <table>
    <tbody><tr>`

    permits.forEach(function (permit, index) {
        html += `<td>`
      
        html += `<table class="permit">`
        html += `<tr><td><img src="${permit.image}" ></td>`
        html += `<tr><td>`
        html += `<table>`
        html += `<tr><td class="text-style-1"><b>${permit.address} | ${permit.type}</b></td></tr>`
        html += `<tr><td class="text-style-0">${permit.date}<td></tr>`
        html += `<tr><td class="text-style-0">${permit.description}<td></tr>`
        html += `<tr><td class="text-style-0"><b>Property Owner:</b> ${permit.property_owner}<td></tr>`
        html += `<tr><td class="text-style-0"><b class="text-style-0">Contractor:</b> ${permit.contractor_name}<td></tr>`
        html += `</table>`
        html += `</table>`
        html += `</td>`
        html += '</tr><tr>'
    })

    html += '</tr></tbody></table>'
    content += html;
    content += `</td></tr></table>`;
    return content
}
