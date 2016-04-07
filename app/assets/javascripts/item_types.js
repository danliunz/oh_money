$(document).ready(function() {
  init_item_type_autocomplete();
  init_add_parent_item_type();
});

function add_parent_item_type() {
  item_type_name = $('#parent_item_type_input').val();

  if(item_type_name) {
    $('#parent_item_types_panel .list-group li:nth-last-of-type(2)').after(
      '<li class="list-group-item">' +
      item_type_name +
      ' <button class="btn btn-primary btn-sm">edit</button> ' +
      ' <button class="btn btn-danger btn-sm">delete</button>' +
      '</li>');

    $('#parent_item_type_input').val("");

    $('select[name="item_type[parents][]"]').append(
      '<option selected="true" value="' + item_type_name + '">' +
      item_type_name + '</option>');
  }
}

function init_add_parent_item_type() {
  $('#add_parent_item_type_btn').click(function(event) {
    add_parent_item_type();
  });

  $('#parent_item_type_input').keypress(function(event) {
    if(event.which == 13) { // enter key
      event.preventDefault();

      add_parent_item_type();
    }
  });
}
