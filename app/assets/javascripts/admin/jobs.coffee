$ ->
  $(document).on 'change', '#job_countries', (evt) ->
    $.ajax '../../../states/update_job_states',
      type: 'GET'
      dataType: 'script'
      data: {
        country_id: $("#job_countries").val()
        selected_states: $("#job_states").val()
      }
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        console.log("Dynamic country select OK!")
