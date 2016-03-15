$(document).ready(function() {
  init_add_tag();
});

function add_tag() {
  tag = $('#tag_input').val().trim();
  if (tag) {
    $('.tags-panel').append(
      '<span class="label label-success">' + tag + '</span>'
    ).append(
      '<input type="hidden" name="expense_entry[tags][][name]"' +
      '       value="' + tag + '" />'
    );

    // clear input for next tag entry
    $('#tag_input').val("");
  }
}

function init_add_tag() {
  // add a new tag
  $('#add_tag_btn').click(function(event) {
    add_tag();

    $('#tag_input').focus();
  });

  // press enter in text input
  // 1. add a new tag
  // 2. DO NOT submit the form
  $('#tag_input').keypress(function(event) {
    if (event.which == 13) { // enter key
      add_tag();
      event.preventDefault();
    }

  });
}
