

var hoz = function(type, start_min, start_max, range) {
  var slider = document.getElementById(type + '_range');

  var default_range = {
    'min': [ 0 ],
    '33%': [ 25, 5 ],
    '66%': [ 100, 25 ],
    '90%': [ 250, 250 ],
    'max': [ 1000 ]
  }

  var range = range ? range : default_range

  noUiSlider.create(slider, {
    start: [start_min, start_max],
    range: range,
    step: 1,
    connect: true, // Display a colored bar between the handles
    orientation: 'horizontal', // Orient the slider vertically
    behaviour: 'tap-drag', // Move handle on tap, bar is draggable

  });

  var min = document.getElementById(type + '_min');
  var max = document.getElementById(type + '_max');

  var min_show = document.getElementById(type + '_min_show');
  var max_show = document.getElementById(type + '_max_show');

  // When the input changes, set the slider value
  min.addEventListener('change', function(){
    slider.noUiSlider.set([null, this.value]);
  });

  max.addEventListener('change', function(){
    slider.noUiSlider.set([null, this.value]);
  });

  // When the slider value changes, update the input and span
  slider.noUiSlider.on('update', function(values, handle) {
    if (handle == 1) {
      max.value = values[handle];
      max_show.innerHTML = parseInt(values[handle]);
    } else {
      min.value = values[handle];
      min_show.innerHTML = parseInt(values[handle]);
    }
  });

  slider.noUiSlider.on('change', function(){
    var filter = require('web/static/js/filter')

    filter.getStreams();
  });
}

export {hoz};