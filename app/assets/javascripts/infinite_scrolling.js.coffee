//= require jquery.infinite-pages
$ ->
  # Configure infinite table
  $('.infinite-table').infinitePages
    # debug: true
    buffer: 3000
    loading: ->
      $(this).text('...')
    error: ->
      $(this).button('Error')
