$(document).ready(function () {

    d3.json("/articles.json").then(function (articles) {
        articles.forEach(function (article, index) {
            var option = document.createElement("option");
            option.text = `News Story #${index}: ${article.source} - ${article.title}, ${article.caption}`;
            option.value = index;
            $(".news #leftValues").append(option);
        });
    });

    d3.json("/events.json").then(function (articles) {
        articles.forEach(function (article, index) {
            var option = document.createElement("option");
            option.text = `Event #${index}: ${article.datetime} - ${article.title}, ${article.about}`;
            option.value = index;
            $(".events #leftValues").append(option);
        });
    });

    d3.json("/headlines.json").then(function (articles) {
        articles.forEach(function (article, index) {
            var option = document.createElement("option");
            option.text = `Story #${index}: ${article.source} - ${article.title}, ${article.caption}`;
            option.value = index;
            $(".headlines #leftValues").append(option);
        });
    });

    addListboxObserver(".news")
    addListboxObserver(".events")
    addListboxObserver(".headlines")
})

function addListboxObserver(className) {
    $(`${className} #btnLeft`).click(function () {
        var selectedItem = $(`${className} #rightValues option:selected`);
        $(`${className} #leftValues`).append(selectedItem);
    });

    $(`${className} #btnRight`).click(function () {
        var selectedItem = $(`${className} #leftValues option:selected`);
        $(`${className} #rightValues`).append(selectedItem);
    });

    $(`${className} #rightValues`).change(function () {
        var selectedItem = $(`${className} #rightValues option:selected`);
        $(`${className} #txtRight`).val(selectedItem.text());
    });
}
