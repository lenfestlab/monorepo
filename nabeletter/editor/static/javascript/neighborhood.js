function neighborhood(result) {
    const title = result["title"]
    const text = result["text"]

    return `
<table class="section">
<tr><td>${text}</td></tr>
</table>
`
}
