function weather(results) {
  const data = results["data"]
  const summary = results["summary"]
  const title = results["title"]
    
  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content-47">`;
    
  var html = `<table><tr><td>`
  html += `<table  class="weather"><tr>`

  html += ``
  
    data.forEach(function (day_data, index) {
      
      day_data_icon = day_data['icon']
      day = day_data['dayofweek']
      
      html += `
          <td>
            <table>
            <tr>
            <td>
              ${day_data_icon}
            </td>
            </tr>
            </table>
            <div class="day">${day}</div>
          </td>
      `

    })

  
    html += `</tr>`
  
    html += `<tr><td colspan=7>`
    
    html += `</td></tr></table>`
    html += summary
    html += `</td></tr></table>`

    content += html;
    content += `</td></tr></table>`;
    return content
}
