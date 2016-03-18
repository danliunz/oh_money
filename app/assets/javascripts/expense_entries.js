$(document).ready(function() {
  init_item_type_autocomplete();

  init_add_tag();
  init_tag_autocomplete();
});

function show_autocomplete_suggestions(suggestions, $dropdown) {
  if (suggestions.length <= 0) {
    $dropdown.removeClass('open');
  } else {
    var $dropdown_menu = $dropdown.find('.dropdown-menu');
    $dropdown_menu.empty();

    $.each(suggestions, function(index, name) {
      $dropdown_menu.append(
        '<li><a href="javascript:void(0)">' + name + '</a></li>'
      );
    });

    $dropdown.addClass('open');
  }
}

function init_autocomplete($input, $dropdown, source_url,
                           display_suggestion_fn) {
  // get suggested names from server based on user input
  $input.on('input', function(event) {
    var prefix = $(this).val().trim();
    if (prefix) {
      $.get(source_url, { prefix: prefix }, display_suggestion_fn);
    } else {
      display_suggestion_fn([]);
    }
  });

  // pressing 'arrow-down' key in text input moves focus to dropdown menu
  var $dropdown_menu = $dropdown.find('.dropdown-menu');

  $input.keydown(function(event) {
    if (event.which === 40) { // 'arrow-down' key
      $dropdown_menu.find('li:first-child a').focus();
    }
  });

  // fill text input when one suggestion is clicked
  $dropdown_menu.on('click', 'a', function(event) {
    $input.val($(this).text()).focus();
  });
}

function init_item_type_autocomplete() {
  init_autocomplete(
    $('.item-types-panel input'),
    $('.item-types-panel .dropdown'),
    '/item_types/suggestions.json',
    display_item_type_suggestions
  );
}

function display_item_type_suggestions(suggested_names) {
  var $dropdown = $('.item-types-panel .dropdown');
  show_autocomplete_suggestions(suggested_names, $dropdown);
}

function init_tag_autocomplete() {
  init_autocomplete(
    $('#tag_input'),
    $('.tag-input-panel .dropdown'),
    '/tags/suggestions.json',
    display_tag_suggestions
  );

  // get suggested names from server based on user input
  var $input = $('#tag_input');
  $input.on('input', function(event) {
    var prefix = $(this).val().trim();
    if (prefix) {
      $.get('/tags/suggestions.json', { prefix: prefix },
        display_tag_suggestions
      );
    } else {
      display_tag_suggestions([]);
    }
  });

  // pressing 'arrow-down' key in text input moves focus to dropdown menu
  var $dropdown_menu = $('.tag-input-panel .dropdown-menu');

  $input.keydown(function(event) {
    if (event.which === 40) { // 'arrow-down' key
      $dropdown_menu.find('li:first-child a').focus();
    }
  });

  // fill text input when suggested name is clicked
  $dropdown_menu.on('click', 'a', function(event) {
    $input.val($(this).text()).focus();
  });
}

function display_tag_suggestions(suggested_names) {
  var $dropdown = $('.tag-input-panel .dropdown');
  show_autocomplete_suggestions(suggested_names, $dropdown);
}

function init_add_tag() {
  // click on 'add tag' button
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

function add_tag(tag) {
  var tag = tag ? tag : $('#tag_input').val().trim();
  if (!tag) return;

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

  // initialize popover for removing the newly added tag control
  $('.tags-panel a:last-of-type').popover(
    {
      container: 'body',
      // trigger: 'focus',
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


