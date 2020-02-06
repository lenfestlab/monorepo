function reviews(results) {
    const reviews = results["data"]
    const title = results["title"]

    var html = `
    <table class="section review">
    <tbody>`

    reviews.forEach(function (review, index) {
      var date = new Date(review.date.datetime)
      html += `<tr><td><b>${review.title}</b></td></tr>`
      html += `<tr><td>${date}<td></tr>`
      if (review.description != null) {
        html += `<tr><td>${review.description}<td></tr>`
      }
      if (review.people != null) {
        review.people.forEach(function (person, index) {
          html += `<tr><td>${person.title}: ${person.name}<td></tr>`
        });        
      }
      html += `<tr><td><br><td></tr>`
    });

    html += '</tbody></table>'
    return html
}
