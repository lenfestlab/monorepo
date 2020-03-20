function markup(results, body = null) {

    if (body == null) {
        body = document.body;
    }
    var sections = [];
    results.forEach(function (result, index) {
        let type = result["type"];
        let title = result["title"];

        content = ``;
        if (type == "weather") {
          content += weather(result);
        } else if (type == "news") {
            content += news(result);
        } else if (type == "events") {
            content += events(result);
        } else if (type == "safety") {
            content += safety(result);
        } else if (type == "history") {
          content += history(result);
        } else if (type == "answer") {
          content += answer(result);
        } else if (type == "stats") {
          content += stats(result);
        } else if (type == "permits") {
          content += permits(result);
        } else if (type == "feedback") {
            content += feedback(result);
        } else if (type == "tweets") {
            content += tweets(result);
        } else if (type == "neighborhood") {
            content += neighborhood(result);
        } else if (type == "reviews") {
            content += reviews(result);
        }
        
        sections.push(content)
    })

    var html = `
        <table class="main" >
          <thead><tr><td>
            <table id="inner" class="header"><tr><td>
              <table id="inner" class="header-title"><tr><td>${header()}</td></tr></table>
            </td></tr></table>
          </td></tr></thead>
    `;

    sections.forEach(function (section, index) {
        html += `<tr><td>`
        html += `<table><tr><td>${section}</td></tr></table>`
        html += `</td></tr>`

    })

    html += `<tfoot><tr><td>${footer()}</td></tr></tfoot>`
    html += `</table>`

    return html;

}
