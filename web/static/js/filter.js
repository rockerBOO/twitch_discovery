function Filter() {}

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

    $("#stream-blocks").html(items.join(""))
    history.pushState(params, "Streams - Discovery", "/streams?"+params+"&offset="+getQueryParam('offset'));


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

function offset(direction, limit) {
  var offset = getQueryParam("offset")

  if (offset == null || offset == "null") {
    offset = 0;
  }

  if (direction == "previous") {
    return parseInt(offset) - limit;
  }

  return parseInt(offset) + limit;
}

module.exports = Filter;
