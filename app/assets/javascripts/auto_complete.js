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
}

function display_tag_suggestions(suggested_names) {
  var $dropdown = $('.tag-input-panel .dropdown');
  show_autocomplete_suggestions(suggested_names, $dropdown);
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

