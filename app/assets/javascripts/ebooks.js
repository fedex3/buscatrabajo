$(function(){ // document ready
  $(".ebooks").each(function(e) {
    $("#ebook-download").click(function() {
      $("body, html").animate({ 
        scrollTop: $("#ebook-registration").offset().top - 80
      }, 600);
    });

    /*Popup Contacto POST*/
    $("#btn_ebook_user_submit").on("click",function(event){
      $('#btn_ebook_user_submit').attr('disabled', '');
      var txt_ebook_user_email = $("#txt_ebook_user_email").val();
      var txt_ebook_user_first_name = $("#txt_ebook_user_first_name").val();
      var txt_ebook_user_last_name = $("#txt_ebook_user_last_name").val();
      var txt_ebook_user_company = $("#txt_ebook_user_company").val();
      var txt_ebook_user_phone = $("#txt_ebook_user_phone").val();
      var txt_ebook_user_position = $("#txt_ebook_user_position").val();
      var txt_ebook_user_analytics_client_id = $("#txt_ebook_user_analytics_client_id").val();
      var txt_ebook_name_id = $("#txt_ebook_name_id").val();
      var txt_locale = $('#locale')[0].innerHTML;
      var txt_ebook_subscribe_to_newsletter = $("#subscribe_to_newsletter").is(":checked") ? true : false;
      
      $.ajax({
        type: "POST",
        //contentType: "application/json",
        dataType: "json",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/" + txt_locale + "/ebooks/" + txt_ebook_name_id + '/ebook_users', 
        data: { ebook_user: { 
          email: txt_ebook_user_email,
          first_name: txt_ebook_user_first_name,
          last_name: txt_ebook_user_last_name,
          company: txt_ebook_user_company,
          phone: txt_ebook_user_phone,
          position: txt_ebook_user_position,
          analytics_client_id: txt_ebook_user_analytics_client_id,
          subscribe_to_newsletter: txt_ebook_subscribe_to_newsletter
        } },
        success: function(resp){
          $('input[name=txt_ebook_user_email]').val('');
          $('input[name=txt_ebook_user_first_name]').val('');
          $('input[name=txt_ebook_user_last_name]').val('');
          $('input[name=txt_ebook_user_company]').val('');
          $('input[name=txt_ebook_user_phone]').val('');
          $('input[name=txt_ebook_user_position]').val('');
          $('#ebook-registration-form').hide();
          $('#ebook-registration-success').show();
          $('#ebook-registration-alert').hide();
        },
        error: function(resp){
          var errors = jQuery.parseJSON(resp.responseText).errors;
          $('#btn_ebook_user_submit').removeAttr('disabled');
          $('#ebook-registration-alert').show();
          $("label[for='ebook-registration-error']").html(errors);
        }
      });
    });
  });  
});
