$(function(){ // document ready
  $(".courses").each(function(e) {
    $("#courses-nav-button").click(function() {
      $("body, html").animate({ 
        scrollTop: $("#courses_contact").offset().top - 80
      }, 600);
    });

    $("#courses-header-button").click(function() {
      $("body, html").animate({ 
        scrollTop: $("#courses_contact").offset().top - 80
      }, 600);
    });

    $(window).scroll(function(){ // scroll event
      /*Social bar*/
      var limitDown = $('#courses_contact').offset().top - 750;
      var limitTop = $('#section-title').offset().top;
      var windowTop = $(window).scrollTop(); // returns number
      

      if (windowTop > limitDown || windowTop < limitTop ) {
        $("#courses-nav-button").hide(); 
      } else {
        $("#courses-nav-button").show();
      }
    });

    $("#btn_contact_send_mail").on("click",function(){
      $('#btn_contact_send_mail').attr('disabled', '');
      ga('send', 'event', 'Contact', 'Courses', '');
      var txtmessage = $("#txt_contact_message").val();
      var txt_locale = $('#locale')[0].innerHTML;
      $.ajax({
        type: "POST",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/" + txt_locale + "/contactos",
        data: { contact: { 
          email: $('input[name=txt_contact_email]').val(), 
          name: $('input[name=txt_contact_name]').val(), 
          phone: $('input[name=txt_contact_phone]').val(), 
          contact_type: "COURSES", 
          message: txtmessage } },
        success: function(){
          $('input[name=txt_contact_email]').val('');
          $('input[name=txt_contact_name]').val('');
          $('input[name=txt_contact_phone]').val('');
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

