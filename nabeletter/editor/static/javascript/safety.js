function safety(results) {
    const images = results["images"]
    const caption = results["caption"]
    const title = results["title"]

  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content-47">`;
  
    html = `
<table>
<tbody>
<tr>
${images.map(element => `<td><table><tr><td><img src="${element.url}"></td></tr></table></td>`).join('')}
</tr>
<tr>
<td class="caption" colspan="3">
${caption}
</td>
</tr>
</tbody>
</table>
`

content += html;
content += `</td></tr></table>`;
return content
}
