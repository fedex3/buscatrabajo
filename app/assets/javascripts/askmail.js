$(function(){ // document ready
  $(".askmail").each(function(e) {

    /*Popup Contacto POST*/
    $(document).on("click", "#btn_newsletter_submit", function(e) {
      $('#btn_newsletter_submit').attr('disabled', '');
      var txt_newsletter_email = $("#txt_newsletter_email").val();
      var txt_newsletter_country = $("#txt_newsletter_country").val();
      var txt_analytics_client_id = $("#analytics_client_id").val();
      var txt_askmail_source = $("#txt_askmail_source").val();
      var txt_askmail_medium = $("#txt_askmail_medium").val();
      var txt_askmail_campaign = $("#txt_askmail_campaign").val();
      var txt_askmail_term = $("#txt_askmail_term").val();
        $.ajax({
          type: "POST",
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          url: "/newsletters",
          data: { newsletter: {
            email: txt_newsletter_email,
            country: txt_newsletter_country,
            source: txt_askmail_source,
            medium: txt_askmail_medium,
            campaign: txt_askmail_campaign,
            term: txt_askmail_term,
            origin: 'MODAL'
            } ,
            cid: txt_analytics_client_id  },
          success: function(){
            $('input[name=txt_newsletter_email]').val('');
            $("#modalNewsletter").modal('hide');
            $("#btn_job_application_soft_modal").hide();
            $("#btn_job_application_soft_submit").show();
          },
          error: function(resp){
              var errors = $.parseJSON(resp.responseText).errors;
              $('#btn_newsletter_submit').removeAttr('disabled');
              $('#newsletter-alert').show();
              $("label[for='newsletter-error']").html(errors);
             }
        });
      });

    /*Popup Contacto POST*/
    $(document).on("click", "#newsletter_bottom_close", function(e) {
      $('#newsletter_bottom_form').hide();
    });



    if ($('#txt_show_newsletter').val() == 'true' ){
      setTimeout(function() {
        if (!$('#modalSignUp').is(':visible') && !$('#modalSignIn').is(':visible') && !$('#modalJobApplicationSoft').is(':visible')) {
          $.ajax({
            type: "GET",
            dataType: "script",
            url: "/newsletters/newform",
            data: {},
            success: function(){
              $('#modalNewsletter').modal('show');
            },
            error: function(){
              console.log("error en el newsletter popup");
            }

          });
        }
      }, 15000);

    }


  });
});
