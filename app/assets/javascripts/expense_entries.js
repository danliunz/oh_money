$(document).ready(function() {
  init_item_type_autocomplete();

  init_add_tag();
});

function init_item_type_autocomplete() {
  // get suggestions from server based on current user input
  // and display
  $('.item_types_panel input').on('input', function(event) {
    hint = $(event.target).val();
    if (hint) {
      $.get('/item_types/suggestions.json', { hint: hint },
        display_item_type_suggestions
      );
    } else {
      display_item_type_suggestions([]);
    }
  });

  $dropdown = $('.item_types_panel .dropdown-menu');
  $dropdown.on('click', 'a', function(event) {
    $('.item_types_panel input').val($(this).text().trim());
    $dropdown.hide();
  });
}

function display_item_type_suggestions(item_type_names) {
  $dropdown = $('.item_types_panel .dropdown-menu');

  if (item_type_names.length <= 0) {
    $dropdown.hide();
    return;
  }

  $dropdown.empty();

  $.each(item_type_names, function(index, name) {
    $dropdown.append(
      '<li><a href="javascript:void(0)">' + name + '</a></li>'
    );
  });

  $dropdown.show();
}

function add_tag(tag) {
  tag = tag ? tag : $('#tag_input').val().trim();
  if (!tag) return;

  if (tag) {
    $('.tags-panel')
      .append(
        '<a tabindex="0"  class="btn btn-success" role="button"' +
        '  data-toggle="popover" >' +
          tag +
        '</a>'
      )
      .append(
      '<input type="hidden" name="expense_entry[tags][][name]"' +
      '  value="' + tag + '" />'
      );

    $('.tags-panel a:last-of-type').popover(
      {
        container: 'body',
        trigger: 'focus',
        html: true,
        content: function() {
          index = $(this).index('a');
          return '<button type="button" class="btn btn-warning" ' +
            'onclick="remove_tag(' + index + ')" >' +
            'remove</button>';
        }
      }
    );

    // clear input for next tag entry
    $('#tag_input').val("");
  }
}

function remove_tag(index) {
  $tag_element = $('.tags-panel a').eq(index);

  $tag_element.popover('hide');

  // remove the hidden form input too
  $tag_element.next().remove();
  $tag_element.remove();
}

function init_add_tag() {
  // click on 'add tag' button
  $('#add_tag_btn').click(function(event) {
    add_tag();

    $('#tag_input').focus();
  });

  // press enter in 'add tag' text input
  // 1. add a new tag
  // 2. DO NOT submit the form
  $('#tag_input').keypress(function(event) {
    if (event.which == 13) { // enter key
      add_tag();
      event.preventDefault();
    }
  });
}

