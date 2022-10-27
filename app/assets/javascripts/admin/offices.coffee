$ ->
  $(document).on 'change', '#office_country', (evt) ->
    $.ajax '../../../../../states/update_office_states',
      type: 'GET'
      dataType: 'script'
      data: {
        country_id: $("#office_country option:selected").val()
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic country select OK!")
