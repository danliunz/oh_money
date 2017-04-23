$(document).ready(function() {
  init_item_type_autocomplete();
  init_add_parent_item_type();
  init_remove_parent_item_type();
});

function add_parent_item_type() {
  item_type_name = $('#parent_item_type_input').val();

  if(item_type_name) {
    $('#parent_item_types_panel .list-group li:nth-last-of-type(1)').before(
      '<li class="list-group-item">' +
      ' <a class="btn btn-success disabled">' + item_type_name + '</a>' +
      ' <button type="button" class="close">' +
      '  <span aria-hidden="true">&times;</span> ' +
      ' </button>' +
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

      // close drop-down menu if any
      display_item_type_suggestions([]);

      add_parent_item_type();
    }
  });
}

function init_remove_parent_item_type() {
  $('#parent_item_types_panel').on("click", "button.close", function(event) {
    $list_item = $(this).parent();

    $('select[name="item_type[parents][]"] option:nth-child('
      + ($list_item.index() + 1) + ')').remove();

    $list_item.remove();
  });
}
;
