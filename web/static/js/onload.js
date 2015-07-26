
$("a.preview").click(function(event) {
  "use strict";

  event.preventDefault()

  var channel       = event.currentTarget.getAttribute("data-channel")
  var title         = event.currentTarget.getAttribute("data-title")
  var display_name  = event.currentTarget.getAttribute("data-display-name")

  Player.clearPreview()

  Player.twitchPlayer(channel)
  Player.twitchChat(channel)
  Player.twitchMeta({channel: channel, title: title, display_name: display_name})

  document.getElementById("preview_video").parentNode.parentNode.classList.remove("preview_off")
});

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
