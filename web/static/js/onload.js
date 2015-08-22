
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

$("input[type=radio]").click(function (event) {
  var element = $(event.currentTarget)

  if (this.hasAttribute("data-radio-checked")) {
    console.log("removing checked")
    element.prop('checked', false)

    $(".radio_block input").removeAttr("data-radio-checked")

    Filter.getStreams()
  } else {
    console.log("setting as checked")
    $(".radio_block input").removeAttr("data-radio-checked")

    element.prop("checked", true);
    this.setAttribute("data-radio-checked", true)
  }
});