import {getStreams} from "web/static/js/filter"

var sliders = {}

var hoz_ref = function (slider, ref, start_min, start_max, range) {
  noUiSlider.create(slider, {
    start: [start_min, start_max],
    range: range,
    step: 1,
    connect: true, // Display a colored bar between the handles
    orientation: 'horizontal', // Orient the slider vertically
    behaviour: 'tap-drag', // Move handle on tap, bar is draggable
  });

  var ref_min = document.getElementById(ref + '_min');
  var ref_max = document.getElementById(ref + '_max');

  var min_show = document.getElementById(ref + '_min_show');
  var max_show = document.getElementById(ref + '_max_show');

  slider.noUiSlider.on('update', function(values, handle) {
    if (handle == 1) {
      ref_max.value = values[handle]
      max_show.innerHTML = parseInt(values[handle]);
      document.getElementById(ref +"_max_meta").innerHTML = parseInt(values[handle])

      sliders[ref].noUiSlider.set([null, values[handle]])
    } else {
      ref_min.value = values[handle]
      min_show.innerHTML = parseInt(values[handle]);
      document.getElementById(ref +"_min_meta").innerHTML = parseInt(values[handle])
      sliders[ref].noUiSlider.set([values[handle], null])
    }
  });

  slider.noUiSlider.on('change', function(){
    getStreams();
  });
}

var hoz = function(slider, type, start_min, start_max, range) {
  sliders[type] = slider == null ? document.getElementById(type + '_range') : slider;

  var default_range = {
    'min': [ 0 ],
    '33%': [ 25, 5 ],
    '66%': [ 100, 25 ],
    '90%': [ 250, 250 ],
    'max': [ 1000 ]
  }

  var range = range ? range : default_range

  noUiSlider.create(sliders[type], {
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
    sliders[type].noUiSlider.set([this.value, null]);
  });

  max.addEventListener('change', function(){
    sliders[type].noUiSlider.set([null, this.value]);
  });

  // When the slider value changes, update the input and span
  sliders[type].noUiSlider.on('update', function(values, handle) {
    if (handle == 1) {
      max.value = values[handle];
      max_show.innerHTML = parseInt(values[handle]);
    } else {
      min.value = values[handle];
      min_show.innerHTML = parseInt(values[handle]);
    }
  });

  sliders[type].noUiSlider.on('change', function(){
    getStreams();
  });
}

export {hoz, hoz_ref};