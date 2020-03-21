function weather(results) {
  const data = results["data"]
  const summary = results["summary"]
  const title = results["title"]
    
  assets = {
    'cloudy' : 'https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/cloudy-icon_scaz8x.png',
    'lightning' : 'https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/lightning-icon_p5mfco.png',
    'snow' : 'https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/snow-icon_wyugso.png',
    'rain' : 'https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/rain-icon_p3zrmg.png',
    'fog' : 'https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/fog-icon_x3crqn.png',
    'clear-day' : 'https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/sun-icon_utlwwb.png',
    'partly-cloudy-day' : 'https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/half-cloudy-icon_eltwzz.png',
  }
    
  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content-47">`;
    
  var html = `<table><tr><td>`
  html += `<table  class="weather"><tr>`

  html += ``
  
    data.slice(0,  7).forEach(function (day_data, index) {
      
      day_data_icon = day_data['icon']
      day = day_data['dayofweek']
      
      html += `
          <td>
            <table>
            <tr> 
            <td>
              <img src=${assets[day_data_icon]} >
            </td>
            </tr>
            <tr> 
            <td class="day">
              ${day}
            </td>
            </tr>


            </table>
          </td>
      `

    })

  
    html += `</tr>`
  
    html += `<tr><td colspan=7>`
    
    html += `</td></tr></table>`
    html += `<table><tr><td class="darksky">* Weather Data Powered by Dark Sky</tr></td></table>`
    html += summary
    html += `</td></tr></table>`

    content += html;
    content += `</td></tr></table>`;
    return content
}
