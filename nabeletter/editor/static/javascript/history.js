function history(result) {
    const title = result["title"]
    const images = result["images"]
    const caption = result["caption"]

    return `
<table class="section">
<tr>
${images.map(element => `<td><table><tr><td><img src="${element.url}"></td></tr></table></td>`).join('')}
</tr>
<tr><td class="caption" colspan="2">${caption}</td></tr>
</table>
`
}
