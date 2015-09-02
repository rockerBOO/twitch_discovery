var Filter = function (){}

// var offset = 0;

Filter.prototype.getStreams = function () {
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
            +    '<img src="'+val["preview"]["large"]+'" onerror="imgError(this);">'
            +  '</a>'
            +  '<div>'
            +    '<a onclick="activatePreview(this);" class="preview" href="javascript:;"'
            +      'data-channel="'+val["channel"]["name"]+'"'
            +      'data-title="'+val["channel"]["status"]+'"'
            +      'data-display-name="'+val["channel"]["display_name"]+'"'
            +      'data-game="'+val["channel"]["game"]+'"'
            +      'data-viewers="'+val["viewers"]+'"'
            +      'data-followers="'+val["channel"]["followers"]+'"'
            +      'data-views="'+val["channel"]["views"]+'"'
            +    '><i class="fa fa-eye"></i> Preview</a>'
            +  '</div>'
            +'</div>'

            +'<div class="stream_meta">'
            +  '<h4><a href="'+val["channel"]["url"]+'" title="'+val["channel"]["status"]+'">'+val["channel"]["status"]+'</a></h4>'
            +  '<span class="views">'+val["viewers"]+' viewers </span>'
            +  '<span class="name">on <a href="'+val["channel"]["url"]+'">'+val["channel"]["display_name"]+'</a></span>'
            + '</div>'
          +'</div>';

        items.push(block)
    })

    if (items.length == 0) {
      $("#stream-blocks").html('<div id="images_404"><img src="/images/404-top.svg"><br><img src="/images/404-bottom.svg"></div>')
    } else {
      $("#stream-blocks").html(items.join(""))
    }

    history.pushState(params, "Streams - Discovery", "/streams?"+params+"&offset="+query_offset());

    console.log("Updating next stream url", "/streams?"+params+"&offset="+offset("next", 24))
    console.log("Updating previous stream url", "/streams?"+params+"&offset="+offset("previous", 24))

    $("#pagination_next").attr("data-next", "/streams?"+params+"&offset="+offset("next", 24))
    $("#pagination_previous").attr("data-previous", "/streams?"+params+"&offset="+offset("previous", 24))
  })
}

function getQueryParam(param) {
  var result = null;

  location.search.substr(1)
    .split("&")
    .some(function(item) { // returns first occurence and stops
      return item.split("=")[0] == param && (result = item.split("=")[1])
    })

  return result
}

function query_offset() {
  var offset = getQueryParam("offset")

  if (offset == null || offset == "null") {
    offset = 0;
  }

  return parseInt(offset);
}

function offset(direction, limit) {
  if (direction == "previous") {
    return query_offset() - limit;
  }

  return query_offset() + limit;
}

$("#filter_form :input").change(function(event) {
  var filter = new Filter()
  filter.getStreams()
});

$("#filter_form").submit(function (event) {
  event.preventDefault()

  var filter = new Filter()
  filter.getStreams()
});

$("#languages ul li a").click(function (event) {
  console.log("Setting language")

  var lang = $(this).attr("data-lang")
  $("#language-input").val(lang)

  $(this).addClass("active")

  var filter = new Filter()
  filter.getStreams()
})

$("input[type=radio]").click(function (event) {
  var element = $(event.currentTarget)

  if (this.hasAttribute("data-radio-checked")) {
    console.log("removing checked")
    element.prop('checked', false)

    $(".radio_block input").removeAttr("data-radio-checked")

    var filter = new Filter()
    filter.getStreams()
  } else {
    console.log("setting as checked")
    $(".radio_block input").removeAttr("data-radio-checked")

    element.prop("checked", true);
    this.setAttribute("data-radio-checked", true)
  }
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

module.exports = Filter;
