$(function(){ // document ready
  $(".resources").each(function(e) {

    $(window).scroll(function(){ // scroll event
      var windowTop = $(window).scrollTop(); // returns number
      var limitSubHeader = 0
      if ($('#navbar_subheader_limit').length){
        limitSubHeader = $('#navbar_subheader_limit').offset().top - 40;
      }
      if (windowTop > limitSubHeader) {
        if (!$('#navbar_subheader_employer_branding').hasClass('navbar-subheader-employer-branding-bottom')){
          $('#navbar_subheader_employer_branding').addClass('navbar-subheader-employer-branding-bottom');
        }
      } else {
        if ($('#navbar_subheader_employer_branding').hasClass('navbar-subheader-employer-branding-bottom')){
          $('#navbar_subheader_employer_branding').removeClass('navbar-subheader-employer-branding-bottom');
        }
      }
    });
    if(window.screen.width < 500 ){
      $('.shorten-name-mobile')[0].innerHTML = "Coaching";
    }
    $("#employer-branding-header-contact").click(function() {
       $("body, html").animate({ 
        scrollTop: $("#employer_branding_contact").offset().top - 80
      }, 600);
    });

    $("#employer_branding_start").click(function() {
       $("body, html").animate({ 
        scrollTop: $("#employer_branding_contact").offset().top - 80
      }, 600);
    });

    
    $("#btn_contact_send_mail").on("click",function(){
      $('#btn_contact_send_mail').attr('disabled', '');
      var txtmessage = $("#txt_contact_message").val();
      var txt_locale = $('#locale')[0].innerHTML;
      ga('send', 'event', 'Contact', 'Resources', '');
      $.ajax({
        type: "POST",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/" + txt_locale + "/contactos",
        data: { contact: { 
          email: $('input[name=txt_contact_email]').val(), 
          name: $('input[name=txt_contact_name]').val(), 
          phone: $('input[name=txt_contact_phone]').val(), 
          company: $('input[name=txt_contact_company]').val(), 
          contact_type: "RESOURCES", 
          message: txtmessage } },
        success: function(){
          $('input[name=txt_contact_email]').val('');
          $('input[name=txt_contact_name]').val('');
          $('input[name=txt_contact_phone]').val('');
          $('input[name=txt_contact_company]').val('');
          $('#txt_contact_message').val('');
          $('#contact-alert').hide();
          $("label[for='contact-error']").html('');
          $('#contact-thanks').show();
        },
        error: function(resp){
          var errors = $.parseJSON(resp.responseText).errors;
          $('#btn_contact_send_mail').removeAttr('disabled');
          $('#contact-alert').show();
          $("label[for='contact-error']").html(errors);
         }
      });
     });
  });  
});
