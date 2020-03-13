function markup(results, body = null) {

    if (body == null) {
        body = document.body;
    }
    var sections = [];
    results.forEach(function (result, index) {
        let type = result["type"];
        let title = result["title"];

        sections.push(`<tr><td class="title">${title}</td></tr>`);
        if (type == "weather") {
          sections.push(weather(result));
        } else if (type == "news") {
            sections.push(news(result));
        } else if (type == "events") {
            sections.push(events(result));
        } else if (type == "safety") {
            sections.push(safety(result));
        } else if (type == "history") {
          sections.push(history(result));
        } else if (type == "stats") {
          sections.push(stats(result));
        } else if (type == "permits") {
          sections.push(permits(result));
        } else if (type == "feedback") {
            sections.push(feedback(result));
        } else if (type == "tweets") {
            sections.push(tweets(result));
        } else if (type == "neighborhood") {
            sections.push(neighborhood(result));
        } else if (type == "reviews") {
            sections.push(reviews(result));
        }
    })

    const markup = `
        <table class="main" >
        <thead class="header"><tr><td>${header()}</td></tr></thead>
        ${sections.map(section => `<tr><td>${section}</td></tr>`).join('')}
        
        <tfoot class="footer"><tr><td>${footer()}</td></tr></tfoot>
        </table>
    `;

    return markup;

}
