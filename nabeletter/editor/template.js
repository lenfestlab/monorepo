function render(results) {

    var sections = []
    results.forEach(function (result, index) {
        let type = result["type"]
        let title = result["title"]

        sections.push(`<tr><td class="title">${title}</td></tr>`)
        if (type == "news") {
            sections.push(news(result))
        } else if (type == "events") {
            sections.push(events(result))
        } else if (type == "safety") {
            sections.push(safety(result))
        } else if (type == "history") {
            sections.push(history(result))
        } else if (type == "feedback") {
            sections.push(feedback(result))
        }

    })

    const markup = `
        <table class="main" >
        <thead class="header"><tr><td>${header()}</td></tr></thead>
        ${sections.map(section => `<tr><td>${section}</td></tr>`).join('')}
        <tfoot class="footer"><tr><td>${footer()}</td></tr></tfoot>
        </table>
    `;

    document.body.innerHTML = markup;

}


$(document).ready(function () {
    d3.json("/template.json").then(function (results) {
        render(results);
    });
});
