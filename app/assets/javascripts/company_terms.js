$(function(){ // document ready
  $(".company_terms").each(function(e) {
    /*Popup Contacto POST*/
    $("#btn_company_terms_submit").on("click",function(event){
      $('#btn_company_terms_submit').attr('disabled', '');
      var txt_company_terms_email = $("#txt_company_terms_email").val();
      var txt_company_terms_name = $("#txt_company_terms_name").val();
      var txt_company_terms_phone = $("#txt_company_terms_phone").val();
      var txt_company_terms_position = $("#txt_company_terms_position").val();
      var txt_company_name_id = $("#txt_company_name_id").val();
      
        $.ajax({
          type: "POST",
          //contentType: "application/json",
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          url: "/companies/" + txt_company_name_id + "/company_terms", 
          data: { company: { 
            terms_accepted_email: txt_company_terms_email,
            terms_accepted_name: txt_company_terms_name,
            terms_accepted_phone: txt_company_terms_phone,
            terms_accepted_position: txt_company_terms_position
             } },
          success: function(){
            $('input[name=txt_company_terms_email]').val('');
            $('input[name=txt_company_terms_name]').val('');
            $('input[name=txt_company_terms_phone]').val('');
            $('input[name=txt_company_terms_position]').val('');
            $('#company-terms-registration-form').hide();
            $('#company-terms-success').show();
            $('#company-terms-alert').hide();
          },
          error: function(resp){
            var errors = jQuery.parseJSON(resp.responseText).errors;
            $('#btn_company_terms_submit').removeAttr('disabled');
            $('#company-terms-alert').show();
            $("label[for='company-terms-error']").html(errors);
           }
        });
      });
  });  
});
