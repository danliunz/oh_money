function debug(text) {
  $('#console').empty().text(text);
}

function ExpenseChart(options) {
  if(!options.canvas) {
    throw "ExpenseChart canvas not specified";
  }

  this.data = options.data || [];
  this.max_amount = Math.max.apply(null, this.data.map(function(obj) { return obj.amount; }));

  this.$canvas = options.canvas;

  this.column_width = 5;
  this.column_gap_width = 1;
  this.columns_bounding_box = {
    top: 20,
    left: 30,
    bottom: 20,
    right: 10,
    width: function() { return options.canvas.width() - this.left - this.right; },
    height: function() { return options.canvas.height() - this.top - this.bottom; }
  };

  this.active_column_index = -1;

  this.drag_event = {};
  this.viewport = { start_column_index: 0 };
  this.calculate_viewport();

  this.setup_events();
}

ExpenseChart.prototype.calculate_viewport = function(column_offset = 0) {
  var max_num_of_columns_fitting_bounding_box =
    Math.ceil(this.columns_bounding_box.width() / (this.column_width + this.column_gap_width));

  this.viewport.start_column_index += column_offset;
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

ExpenseChart.prototype.setup_events = function() {
  var chart = this;
  var ctx = this.$canvas.get(0).getContext('2d');

  this.$canvas.mousedown(function(event) {
    chart.active_column_index = -1;
    chart.hide_float_tip();

    chart.drag_event.started = true;
    chart.drag_event.original_pos = { x: event.pageX, y: event.pageY };

    $(this).css('cursor', 'move');
  });

  this.$canvas.mouseup(function(event) {
    var original_pos = chart.drag_event.original_pos;
    var delta = { x: event.pageX - original_pos.x, y: event.pageY - original_pos.y };
    debug('delta (x: ' + delta.x + ', y: ' + delta.y + ')');

    // render updated viewport based on how far the user drags the mouse on the canvas
    var column_offset = Math.ceil(delta.x / (chart.column_width + chart.column_gap_width));
    chart.calculate_viewport(column_offset);
    chart.render();

    chart.drag_event.started = false;
    chart.drag_event.original_pos = null;

    $(this).css('cursor', 'default');
  });

  this.$canvas.parent().mousemove(function(event) {
    if(chart.drag_event.started) return;

    // find the active column under mouse pointer, hightlight it and show float tip
    var x = event.pageX - $(this).offset().left;
    var y = event.pageY - $(this).offset().top;

    var index = chart.get_column(x, y);
    if (chart.active_column_index === index) return;

    var prior_active_column_index = chart.active_column_index;
    chart.active_column_index = index;

    chart.render_column(prior_active_column_index);
    chart.render_column(chart.active_column_index);

    chart.render_float_tip(x, y);

    debug('n = ' + index);
  });
};

ExpenseChart.prototype.get_column = function(x, y) {
  x -= this.columns_bounding_box.left;
  if(x < 0) return -1;

  var column_index_in_viewport = Math.floor(x / (this.column_width + this.column_gap_width));
  var column_index = column_index_in_viewport + this.viewport.start_column_index;
  return column_index <= this.viewport.end_column_index ? column_index : -1;
};

ExpenseChart.prototype.render_float_tip = function(mouse_x, mouse_y) {
  var $tip = $('#float_tip'); // TODO: create the float tip element dynamically so users don't have to specify them in HTML
  if(this.active_column_index >= 0) {
    $tip.css('left', (mouse_x + 10) + 'px');
    $tip.css('top', (mouse_y- 10) + 'px');
    $tip.text('date: ' + this.data[this.active_column_index].date.toLocaleDateString() + ', amount: ' + this.data[this.active_column_index].amount);
    $tip.show();
  } else {
    $tip.hide();
  }
};

ExpenseChart.prototype.hide_float_tip = function() {
  $('#float_tip').hide();
};

ExpenseChart.prototype.render_coordinate_system = function() {
  var ctx = this.$canvas.get(0).getContext('2d');

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
    ctx.moveTo(0, y);
    ctx.lineTo(this.columns_bounding_box.width(), y);
  }
  ctx.stroke();
  ctx.restore();

  ctx.save();
  ctx.font = $('body').css('font');
  ctx.textBaseline = 'middle';

  // 2. render the number associated with each horizontal axis
  var base_amount = Math.ceil(this.max_amount / (number_of_horizontal_lines - 1));
  this.max_amount_in_cooridnate_system = base_amount * (number_of_horizontal_lines - 1);

  for(var i = 0; i < number_of_horizontal_lines; i++) {
    var amount = base_amount * (number_of_horizontal_lines - 1 - i);
    var x = 5;
    var y = this.columns_bounding_box.top + i * (horizontal_line_gap_width + width_of_horizontal_line);

    ctx.fillText(amount, x, y, this.columns_bounding_box.left - x);
  }

  ctx.restore();
};

ExpenseChart.prototype.render_column = function(column_index) {
  if(column_index == null || column_index < 0 || column_index >= this.data.length) return;

  var ctx = this.$canvas.get(0).getContext('2d');
  ctx.save();

  var bounding_box = this.columns_bounding_box;
  ctx.translate(bounding_box.left, bounding_box.top);
  ctx.fillStyle = (column_index == this.active_column_index ? '#5b92ea' : '#1356c1');

  var column_index_in_viewport = column_index - this.viewport.start_column_index;
  var x = this.column_gap_width + (this.column_gap_width + this.column_width) * column_index_in_viewport;
  var height = bounding_box.height() / this.max_amount_in_cooridnate_system * this.data[column_index].amount;
  var y = bounding_box.height() - height;

  ctx.fillRect(x, y, this.column_width, height);

  ctx.restore();
};

ExpenseChart.prototype.render_columns = function() {
  for(var i = this.viewport.start_column_index; i <= this.viewport.end_column_index; i++) {
    this.render_column(i);
  }
};

ExpenseChart.prototype.render = function() {
  this.$canvas.get(0).getContext('2d').clearRect(0, 0, this.$canvas.width(), this.$canvas.height());

  this.render_coordinate_system();
  this.render_columns();
};



