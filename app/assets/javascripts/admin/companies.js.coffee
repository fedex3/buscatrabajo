$ ->
  $(document).on 'change', '#company_countries', (evt) ->
    $.ajax '../../../states/update_company_states',
      type: 'GET'
      dataType: 'script'
      data: {
        country_id: $("#company_countries").val()
        selected_states: $("#company_states").val()
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic country select OK!")
