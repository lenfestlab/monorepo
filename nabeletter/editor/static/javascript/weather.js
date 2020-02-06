function weather(results) {
  const data = results["data"]
  const summary = results["summary"]
    
  var html = `<table class="section"><tr><td>`
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

    return html
}
