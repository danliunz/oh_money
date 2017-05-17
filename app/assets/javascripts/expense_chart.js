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
  this.setup_events();
}

ExpenseChart.prototype.setup_events = function() {
  var chart = this;
  var ctx = this.$canvas.get(0).getContext('2d');

  this.$canvas.parent().mousemove(function(event) {
    var x = event.pageX - $(this).offset().left;
    var y = event.pageY - $(this).offset().top;

    var index = chart.get_column(x, y);
    if(chart.active_column_index === index) return;

    var prior_active_column_index = chart.active_column_index;
    chart.active_column_index = index;

    chart.render_column(prior_active_column_index);
    chart.render_column(chart.active_column_index);

    chart.render_float_tip(x, y);

    $('#console').empty();
    if(index >= 0) {
      $('#console').text('n = ' + index);
    }
  });
};

ExpenseChart.prototype.get_column = function(x, y) {
  x -= this.columns_bounding_box.left;

  var n = Math.ceil(x / (this.column_width + this.column_gap_width));
  if(x >= n * this.column_gap_width + (n - 1) * this.column_width && n <= this.data.length) {
    return n - 1;
  } else {
    return -1;
  }

  // if(n > this.data.length || x < n * this.column_gap_width + (n - 1) * this.column_width) {
    // return -1;
  // }

  // var height = this.$canvas.height() / this.max_amount * this.data[n - 1].amount;
  // if(y >= this.$canvas.height() - height && y <= this.$canvas.height()) {
    // return n - 1;
  // } else {
    // return -1;
  // }
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

  var x = this.column_gap_width + (this.column_gap_width + this.column_width) * column_index;
  var height = bounding_box.height() / this.max_amount_in_cooridnate_system * this.data[column_index].amount;
  var y = bounding_box.height() - height;

  ctx.fillRect(x, y, this.column_width, height);

  ctx.restore();
};

ExpenseChart.prototype.render_columns = function() {
  for(var i = 0; i < this.data.length; i++) {
    this.render_column(i);
  }
};

ExpenseChart.prototype.render = function() {
  this.render_coordinate_system();
  this.render_columns();
};



