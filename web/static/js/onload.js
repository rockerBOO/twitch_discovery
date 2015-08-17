
$("a.preview").click(function(event) {
  event.preventDefault()

  var channel       = event.currentTarget.getAttribute("data-channel")
  var title         = event.currentTarget.getAttribute("data-title")
  var display_name  = event.currentTarget.getAttribute("data-display-name")
  var game          = event.currentTarget.getAttribute("data-game")
  var followers     = event.currentTarget.getAttribute("data-followers")
  var viewers       = event.currentTarget.getAttribute("data-viewers")
  var views         = event.currentTarget.getAttribute("data-views")

  Player.clearPreview()

  Player.twitchPlayer(channel)
  Player.twitchChat(channel)
  Player.twitchMeta({
    channel: channel,
    title: title,
    display_name: display_name,
    game: game,
    viewers: viewers,
    followers: followers,
    views: views
  })

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

$("#filter_form :input").change(function(event) {
  getStreams()
});

$("#filter_form").submit(function (event) {
  event.preventDefault()

  getStreams()
});

function getStreams() {
  var params = $('#filter_form').serialize();

  // console.log(params)
  // console.log("/api/streams?"+params)
  jQuery.getJSON("/api/streams?"+params, function (data) {
    var items = []
    $.each(data, function(key, val) {
      // console.log(key, val)
        var block = '<div class="stream-block mui-col-md-4">'
            + '<div class="stream-image">'
            +  '<a href="'+val["channel"]["url"]+'">'
            +    '<img src="'+val["preview"]["large"]+'">'
            +  '</a>'
            +  '<div>'
            +    '<a class="preview" href="javascript:;"'
            +      'data-channel="'+val["channel"]["name"]+'"'
            +      'data-title="'+val["channel"]["status"]+'"'
            +      'data-display-name="'+val["channel"]["display_name"]+'"'
            +      'data-game="'+val["channel"]["game"]+'"'
            +      'data-viewers="'+val["viewers"]+'"'
            +      'data-followers="'+val["channel"]["followers"]+'"'
            +      'data-views="'+val["channel"]["views"]+'"'
            +    '><i class="fa fa-eye"></i>Preview</a>'
            +  '</div>'
            +'</div>'

            +'<div class="stream_meta">'
            +  '<h4><a href="'+val["channel"]["url"]+'" title="'+val["channel"]["status"]+'">'+val["channel"]["status"]+'</a></h4>'
            +  '<span class="views">'+val["viewers"]+' viewers</span>'
            +  '<span class="name">on <a href="'+val["channel"]["url"]+'">'+val["channel"]["display_name"]+'</a></span>'
            + '</div>'
          +'</div>';

        items.push(block)
    })

    // console.log(items.join(""))

    $("#stream-blocks").html(items.join(""))
    // $("#stream-blocks").appendTo(  );
  })
}