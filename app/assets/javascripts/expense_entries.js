$(document).ready(function() {
  init_add_expense_entry_tag();
});

function init_add_expense_entry_tag() {
  $('#add_expense_entry_tag_btn').click(function(event) {
    tag = $('#expense_entry_tag_input').val().trim();
    if (tag) {
      $('.tags-panel').append(
        '<span class="label label-success">' + tag + '</span>'
      ).append(
        '<input type="hidden" name="expense_entry[tags][][name]"' +
        '       value="' + tag + '" />'
      );
    }
  });
}
