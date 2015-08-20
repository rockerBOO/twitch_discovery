
// $("a.preview").click(function(event) {
//   console.log("Activating preview")
//   event.preventDefault()

//   activatePreview(event.currentTarget)
// });

var filter = require('web/static/js/filter')
var Filter = new filter()

$("#search-fps-toggle").click(function (event) {
  $("#search-fps-options").toggleClass("hide-options")
})

$("#search-mature-toggle").click(function (event) {
  $("#search-mature-options").toggleClass("hide-options")
})

$("#games-search-input").autocomplete({
  serviceUrl: "/games/autocomplete",
  width: "rekt",
  onSelect: function () { $("#filter_form").submit() }
});

$("#filter_form :input").change(function(event) {
  Filter.getStreams()
});

$("#filter_form").submit(function (event) {
  event.preventDefault()

  Filter.getStreams()
});