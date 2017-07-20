function debug(text) {
  $('#console').empty().text(text);
}

function ExpenseChart(options) {
  this.data = options.data || [];

  this.max_amount = Math.max.apply(null, this.data.map(function(obj) { return obj.amount; }));
  if(!isFinite(this.max_amount)) {
    this.max_amount = 0;
  }

  this.$root_element = options.$root_element;
  this.$canvas = $('<canvas></canvas>')
    .attr({ width: this.$root_element.width(), height: this.$root_element.height() })
    .width(this.$root_element.width())
    .height(this.$root_element.height())
    .prependTo(this.$root_element);
  this.canvas_ctx = this.$canvas.get(0).getContext('2d');
  this.$float_tip =$('<div class="float_tip"></div>')
    .appendTo(this.$root_element);

  this.column_width = 3;
  this.column_gap_width = 1;
  this.columns_bounding_box = {
    top: 20,
    left: 50,
    bottom: 30,
    right: 40,
    width: function() { return options.$root_element.width() - this.left - this.right; },
    height: function() { return options.$root_element.height() - this.top - this.bottom; }
  };

  this.active_column_index = -1;

  this.drag_event = {};
  this.init_viewport();

  this.support_touch_events = false;
  this.setup_events();
}

ExpenseChart.prototype.init_viewport = function() {
  var end_column_index = this.data.length - 1;

  var max_num_of_columns_fitting_bounding_box =
    Math.floor(this.columns_bounding_box.width() / (this.column_width + this.column_gap_width));
  var start_column_index = end_column_index - max_num_of_columns_fitting_bounding_box + 1;
  if(start_column_index < 0) { start_column_index = 0; }

  this.viewport = {
    start_column_index: start_column_index,
    end_column_index: end_column_index
  };
};

ExpenseChart.prototype.shift_viewport = function(column_offset) {
  var max_num_of_columns_fitting_bounding_box =
    Math.floor(this.columns_bounding_box.width() / (this.column_width + this.column_gap_width));

  this.viewport.start_column_index -= column_offset;
  if(this.viewport.start_column_index + max_num_of_columns_fitting_bounding_box >= this.data.length) {
    this.viewport.start_column_index = this.data.length - max_num_of_columns_fitting_bounding_box;
  }
  if(this.viewport.start_column_index < 0) {
    this.viewport.start_column_index = 0;
  }

  this.viewport.end_column_index = Math.min(
    this.viewport.start_column_index + max_num_of_columns_fitting_bounding_box - 1,
    this.data.length - 1
  );
};
ExpenseChart.prototype.hightlight_active_column = function(pageX, pageY) {
  var prior_active_column_index = this.active_column_index;

  var x = pageX - this.$canvas.offset().left;
  var y = pageY - this.$canvas.offset().top;
  this.active_column_index = this.get_column(x, y);

  this.render_float_tip(x, y);

  if (this.active_column_index != prior_active_column_index) {
    this.render_column(prior_active_column_index);
    this.render_column(this.active_column_index);
  }
};

ExpenseChart.prototype.setup_events = function() {
  var chart = this;

  this.$canvas.on('touchstart', function(event) {
    chart.support_touch_events = true;

    var touch_point = event.originalEvent.changedTouches[0];
    chart.drag_event.original_pos = { x: touch_point.pageX, y: touch_point.pageY };
    chart.hightlight_active_column(touch_point.pageX, touch_point.pageY);
  });

  this.$canvas.on('touchmove', function(event) {
    chart.active_column_index = -1;
    chart.hide_float_tip();
  });

  this.$canvas.on('touchend', function(event) {
    var original_pos = chart.drag_event.original_pos;
    var touch_point = event.originalEvent.changedTouches[0];
    var delta = { x: touch_point.pageX - original_pos.x, y: touch_point.pageY - original_pos.y };

    // shift viewport based on how far the user moves the touch point on canvas
    var column_offset = Math.ceil(delta.x / (chart.column_width + chart.column_gap_width));
    chart.shift_viewport(column_offset);
    chart.render();
  });

  this.$canvas.mousedown(function(event) {
    if(chart.support_touch_events) return;

    chart.active_column_index = -1;
    chart.hide_float_tip();

    chart.drag_event.started = true;
    chart.drag_event.original_pos = { x: event.pageX, y: event.pageY };

    $(this).css('cursor', 'move');
  });

  this.$canvas.mouseup(function(event) {
    if(chart.support_touch_events) return;

    var original_pos = chart.drag_event.original_pos;
    var delta = { x: event.pageX - original_pos.x, y: event.pageY - original_pos.y };
    debug('delta (x: ' + delta.x + ', y: ' + delta.y + ')');

    // shift viewport based on how far the user drags the mouse on canvas
    var column_offset = Math.ceil(delta.x / (chart.column_width + chart.column_gap_width));
    chart.shift_viewport(column_offset);
    chart.render();

    chart.drag_event.started = false;
    chart.drag_event.original_pos = null;

    $(this).css('cursor', 'default');
  });

  this.$canvas.parent().mouseleave(function(event) {
    if(chart.support_touch_events) return;

    chart.active_column_index = -1;
    chart.hide_float_tip();

    chart.drag_event.started = false;
    chart.drag_event.original_pos = null;
    $(this).css('cursor', 'default');

    chart.render();
  });

  this.$canvas.parent().mousemove(function(event) {
    if(chart.support_touch_events) return;
    if(chart.drag_event.started) return;

    // find the active column under mouse pointer, hightlight it and show float tip
    chart.hightlight_active_column(event.pageX, event.pageY);
  });
};

ExpenseChart.prototype.get_column = function(x, y) {
  x -= this.columns_bounding_box.left;
  if(x < 0) return -1;

  var column_index_in_viewport = Math.ceil(x / (this.column_width + this.column_gap_width)) - 1;
  var column_index = column_index_in_viewport + this.viewport.start_column_index;
  return column_index <= this.viewport.end_column_index ? column_index : -1;
};

ExpenseChart.prototype.render_float_tip = function(mouse_x, mouse_y) {
  var $tip = this.$float_tip;
  var gap_between_mouse_and_tip = 10;
  if(this.active_column_index >= 0) {
    $tip.text('date: ' + this.data[this.active_column_index].date.toLocaleDateString() + ', amount: ' + this.data[this.active_column_index].amount);

    var left = mouse_x + gap_between_mouse_and_tip;
    if(left + $tip.outerWidth() > this.$canvas.width()) {
      left = mouse_x - $tip.outerWidth() - gap_between_mouse_and_tip;
    }

    var top = mouse_y - 10;
    if(top + $tip.outerHeight() > this.$canvas.height()) {
      top = this.$canvas.height() - $tip.outerHeight();
    }

    $tip.css('left', left + 'px');
    $tip.css('top', top + 'px');
    $tip.show();
  } else {
    $tip.hide();
  }
};

ExpenseChart.prototype.hide_float_tip = function() {
  this.$float_tip.hide();
};

ExpenseChart.prototype.render_coordinate_system = function() {
  var ctx = this.canvas_ctx;

  // 1. render horizontal axis lines
  var number_of_horizontal_lines = 5;
  var width_of_horizontal_line = 1;
  var horizontal_line_gap_width = (this.columns_bounding_box.height() - number_of_horizontal_lines * width_of_horizontal_line) / (number_of_horizontal_lines - 1);

  ctx.save();
  ctx.beginPath();

  // note when line width > 1, ctx.lineTo(x, y) treats y as middle of line cap
  ctx.translate(this.columns_bounding_box.left, this.columns_bounding_box.top + width_of_horizontal_line / 2);
  ctx.lineWidth = width_of_horizontal_line;
  ctx.strokeStyle = '#a7aaaf';
  for(var i = 0; i < number_of_horizontal_lines; i++) {
    var y = i * (horizontal_line_gap_width + width_of_horizontal_line);
    ctx.moveTo(-10, y);
    ctx.lineTo(this.columns_bounding_box.width() + 10, y);
  }
  ctx.stroke();
  ctx.restore();

  ctx.save();
  ctx.font = $('body').css('font');
  ctx.textBaseline = 'middle';

  // 2. render the number associated with each horizontal axis
  var base_amount = Math.ceil(this.max_amount / (number_of_horizontal_lines - 1));
  this.max_amount_in_cooridnate_system = base_amount * (number_of_horizontal_lines - 1);

  for(var i = 0; i < number_of_horizontal_lines - 1; i++) {
    var amount = base_amount * (number_of_horizontal_lines - 1 - i);
    var x = 5;
    var y = this.columns_bounding_box.top + i * (horizontal_line_gap_width + width_of_horizontal_line);

    ctx.fillText(amount, x, y, this.columns_bounding_box.left - x);
  }

  ctx.restore();

  // 3. render dates at bottom of the chart
  if(this.data.length > 0) {
    ctx.save();
    ctx.font = $('body').css('font');
    ctx.textBaseline = 'hanging';
    ctx.textAlign = 'center';

    var indexes = [this.viewport.start_column_index];
    if(this.viewport.end_column_index - this.viewport.start_column_index > 10) {
      indexes.push(Math.ceil((this.viewport.start_column_index + this.viewport.end_column_index) / 2));
    }
    if(this.viewport.end_column_index > this.viewport.start_column_index) {
      indexes.push(this.viewport.end_column_index);
    }

    for(var i = 0; i < indexes.length; i++) {
      var date = this.data[indexes[i]].date;
      ctx.fillText(
        date.toLocaleDateString(),
        this.columns_bounding_box.left + (indexes[i] - this.viewport.start_column_index) * (this.column_width + this.column_gap_width),
        this.$canvas.height() - this.columns_bounding_box.bottom + 10
      );
    };

    ctx.restore();
  }
};

ExpenseChart.prototype.render_column = function(column_index) {
  if(column_index == null || column_index < 0 || column_index >= this.data.length) return;

  var ctx = this.canvas_ctx;
  ctx.save();

  var bounding_box = this.columns_bounding_box;
  ctx.translate(bounding_box.left, bounding_box.top);

  var column_index_in_viewport = column_index - this.viewport.start_column_index;
  var x = this.column_gap_width + (this.column_gap_width + this.column_width) * column_index_in_viewport;
  var height = bounding_box.height() / this.max_amount_in_cooridnate_system * this.data[column_index].amount;
  var y = bounding_box.height() - height;

  ctx.fillStyle = (column_index === this.active_column_index ? '#5fa5ef' : '#3849d1');
  ctx.fillRect(x, y, this.column_width, height);

  ctx.restore();
};

ExpenseChart.prototype.render_columns = function() {
  for(var i = this.viewport.start_column_index; i <= this.viewport.end_column_index; i++) {
    this.render_column(i);
  }
};

ExpenseChart.prototype.render = function() {
  this.canvas_ctx.clearRect(0, 0, this.$canvas.width(), this.$canvas.height());

  this.render_coordinate_system();
  this.render_columns();
};



