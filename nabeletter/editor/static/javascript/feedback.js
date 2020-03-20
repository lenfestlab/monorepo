function feedback(results) {
  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content">`;
  
    html = `
<table class="section feedback">
<tr>
<td>
Have feedback?
</td>
</tr>
<tr>
<td>
Send your comments and questions to</td>
</tr>
<tr>
<td>
name@gmail.com</td>
</tr>
</table>
`
  content += html;
  content += `</td></tr></table>`;
  return content
}
