$ ->
  $(document).on 'change', '#user_country', (evt) ->
    $.ajax '../../../states/update_user_states',
      type: 'GET'
      dataType: 'script'
      data: {
        country_id: $("#user_country option:selected").val()
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic country select OK!")
