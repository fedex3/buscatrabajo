$(function(){ // document ready
  $(".webinars").each(function(e) {
    $("#webinar-join-event").click(function() {
      $("body, html").animate({ 
        scrollTop: $("#webinar-registration").offset().top - 80
      }, 600);
    });


    /*Popup Contacto POST*/
    $("#btn_webinar_user_submit").on("click",function(event){
      $('#btn_webinar_user_submit').attr('disabled', '');
      var txt_webinar_user_email = $("#txt_webinar_user_email").val();
      var txt_webinar_user_first_name = $("#txt_webinar_user_first_name").val();
      var txt_webinar_user_last_name = $("#txt_webinar_user_last_name").val();
      var txt_webinar_user_country = $("#txt_webinar_user_country").val();
      var txt_webinar_user_company = $("#txt_webinar_user_company").val();
      var txt_webinar_user_phone = $("#txt_webinar_user_phone").val();
      var txt_webinar_user_position = $("#txt_webinar_user_position").val();
      var txt_webinar_user_comment = $("#txt_webinar_user_comment").val();
      var txt_webinar_user_analytics_client_id = $("#txt_webinar_user_analytics_client_id").val();
      var txt_webinar_name_id = $("#txt_webinar_name_id").val();
      var txt_locale = $('#locale')[0].innerHTML;
      
        $.ajax({
          type: "POST",
          //contentType: "application/json",
          dataType: "json",
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          url: "/" + txt_locale + "/webinars/" + txt_webinar_name_id + '/webinar_users', 
          data: { webinar_user: { 
            email: txt_webinar_user_email,
            first_name: txt_webinar_user_first_name,
            last_name: txt_webinar_user_last_name,
            company: txt_webinar_user_company,
            phone: txt_webinar_user_phone,
            country: txt_webinar_user_country,
            position: txt_webinar_user_position,
            comment: txt_webinar_user_comment,
            analytics_client_id: txt_webinar_user_analytics_client_id
            } },
          success: function(resp){
            $('input[name=txt_webinar_user_email]').val('');
            $('input[name=txt_webinar_user_first_name]').val('');
            $('input[name=txt_webinar_user_last_name]').val('');
            $('input[name=txt_webinar_user_company]').val('');
            $('input[name=txt_webinar_user_phone]').val('');
            $('input[name=txt_webinar_user_position]').val('');
            $('#txt_webinar_user_comment').val('');
            $('#webinar-registration-form').hide();
            $('#webinar-registration-success').show();
            $('#webinar-registration-alert').hide();
            $('.webinar-registration-container h3')[0].innerHTML = "¡Ya estás registrado/a al " + $('h1')[0].innerHTML + "!"
          },
          error: function(resp){
            var errors = jQuery.parseJSON(resp.responseText).errors;
            $('#btn_webinar_user_submit').removeAttr('disabled');
            $('#webinar-registration-alert').show();
            $("label[for='webinar-registration-error']").html(errors);
          }
        });
      });
  });  
});