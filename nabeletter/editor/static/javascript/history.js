function history(result) {
    const title = result["title"]
    const images = result["images"]
    const caption = result["caption"]

  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content-28">`;
  
    html = `
    <table class="content">
    <tr>
    ${images.map(element => `<td><table><tr><td><img src="${element.url}"></td></tr></table></td>`).join('')}
    </tr>
    <tr><td class="caption" colspan="2">${caption}</td></tr>
    </table>
    `

    content += html;
    content += `</td></tr></table>`;
    return content
}
