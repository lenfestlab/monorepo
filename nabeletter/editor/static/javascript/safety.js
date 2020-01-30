function safety(results) {
    const images = results["images"]
    const caption = results["caption"]

    return `
<table class="section">
<tbody>
<tr>
${images.map(element => `<td><table><tr><td><img src="${element.image}"></td></tr></table></td>`).join('')}
</tr>
<tr>
<td class="caption" colspan="3">
${caption}
</td>
</tr>
</tbody>
</table>
`
}
