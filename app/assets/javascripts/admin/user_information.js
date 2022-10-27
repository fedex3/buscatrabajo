$(function () {
  $(".admin_user_informations").each(function(e) {
    $(document).on('click', 'form[role="search"] button[type="submit"]', function(event) {
      event.preventDefault();
      var $form = $(this).closest('form'),
      $input = $form.find('input');

      link = $form.attr('action');
      params = "";
      if ($input.val() != ""){
        if (params == ""){
          params = "?q=" + $input.val();
        } 
        else{
          params = "&q=" + $input.val();
        }
      }

      if ($('#cv_status_filter').val() != "" && $('#cv_status_filter').val() != "undefined"){
        if (params == ""){
          params = "?cv_status=" + $('#cv_status_filter').val();
        } 
        else{
          params += "&cv_status=" + $('#cv_status_filter').val();
        }
      }


      if ($('#rejected_filter').val() != "" && $('#rejected_filter').val() != "undefined"){
        if (params == ""){
          params = "?rejected=" + $('#rejected_filter').val();
        }
        else{
          params += "&rejected=" + $('#rejected_filter').val();
        }
      }

      if ($('#language_filter').val() != "" && $('#language_filter').val() != "undefined"){
        if (params == ""){
          params = "?language=" + $('#language_filter').val();
        }
        else{
          params += "&language=" + $('#language_filter').val();
        }
      }

      if ($('#job_area_filter').val() != "" && $('#job_area_filter').val() != "undefined"){
        if (params == ""){
          params = "?job_area=" + $('#job_area_filter').val();
        }
        else{
          params += "&job_area=" + $('#job_area_filter').val();
        }
      }

      if ($('#study_level_filter').val() != "" && $('#study_level_filter').val() != "undefined"){
        if (params == ""){
          params = "?study_level=" + $('#study_level_filter').val();
        }
        else{
          params += "&study_level=" + $('#study_level_filter').val();
        }
      }

      window.location.href = link + params;
    });
  });

});
