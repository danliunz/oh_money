$(document).ready(function() {
  $('#expense_entry_item_type_name').focus();

  init_item_type_autocomplete();

  init_add_tag();
  init_tag_autocomplete();
});

function init_add_tag() {
  $('#add_tag_btn').click(function(event) {
    add_tag();

    $('#tag_input').focus();
  });

  // press enter in 'add tag' text input
  // 1. add new tag
  // 2. hide auto-complete dropdown if any
  // 3. DO NOT submit the form
  $('#tag_input').keypress(function(event) {
    if (event.which == 13) { // enter key
      add_tag();

      $('.tag-input-panel .dropdown').removeClass('open');

      event.preventDefault();
    }
  });
}

function unescape_html(text) {
  return $('<textarea/>').html(text).text();
}

function add_tag(tag) {
  var tag = tag ? unescape_html(tag) : $('#tag_input').val().trim();
  if (!tag) return;

  $('.tags-panel')
    .append(
      $('<a tabindex="0"  class="btn btn-success" role="button" data-toggle="popover"/>')
        .text(tag)
    )
    .append(
      $('<input type="hidden" name="expense_entry[tags][][name]"/>')
        .attr("value", tag)
    );

  // initialize popover for removing the newly added tag control
  $('.tags-panel a:last-of-type').popover(
    {
      container: 'body',
      trigger: 'focus',
      html: true,
      content: function() {
        index = $('.tags-panel a').index(this);
        return '<button type="button" class="btn btn-warning" ' +
          'onclick="remove_tag(' + index + ')" >' +
          'remove</button>';
      }
    }
  );

  // clear input for next tag entry
  $('#tag_input').val("");
}

function remove_tag(index) {
  var $tag_element = $('.tags-panel a').eq(index);

  $tag_element.popover('hide');

  // remove the hidden form input too
  $tag_element.next().remove();
  $tag_element.remove();
}


