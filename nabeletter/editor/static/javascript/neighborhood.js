function neighborhood(result) {
    const title = result["title"]
    const text = result["text"]

  content = `<table class="section">`;
  content += `<tr><td class="title">${title}</td></tr>`;
  content += `<tr><td class="content-47">`;
  
    html = `
    <table>
    <tr><td>${text}</td></tr>
    </table>
    `
  
  content += html;
  content += `</td></tr></table>`;
  return content
}
