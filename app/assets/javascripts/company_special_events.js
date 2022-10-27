//= require special_events/application.js
//Todo esto creo que no se usa más
$(function(){
    $("#btn_event_user_submit").on("click",function(event){
      $('#btn_event_user_submit').attr('disabled', '');
      var txt_event_user_first_name = $("#txt_event_user_first_name").val();
      var txt_event_user_last_name = $("#txt_event_user_last_name").val();
      var txt_event_user_email = $("#txt_event_user_email").val();
      var txt_event_user_phone = $("#txt_event_user_phone").val();
      var txt_event_user_company = $("#txt_event_user_company").val();
      var txt_event_user_position = $("#txt_event_user_position").val();
      var txt_event_user_country = $("#txt_event_user_country").val();
      var txt_event_user_acquisition_channel = $("#txt_event_user_acquisition_channel").val();
      var txt_event_user_seniority = $("#txt_event_user_seniority").val();
      var txt_company_special_event_code = $("#txt_company_special_event_code").val();
      var txt_locale = $('#locale')[0].innerHTML;

      $.ajax({
        type: "POST",
        dataType: "json",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: '/' + txt_company_special_event_code + '/event_users',
        data: { event_user: {
          first_name: txt_event_user_first_name,
          last_name: txt_event_user_last_name,
          email: txt_event_user_email,
          phone: txt_event_user_phone,
          company: txt_event_user_company,
          position: txt_event_user_position,
          country: txt_event_user_country,
          acquisition_channel: txt_event_user_acquisition_channel,
          seniority: txt_event_user_seniority
          } },
        success: function(resp){
          $('input[name=txt_event_user_first_name]').val('');
          $('input[name=txt_event_user_last_name]').val('');
          $('input[name=txt_event_user_email]').val('');
          $('input[name=txt_event_user_phone]').val('');
          $('input[name=txt_event_user_company]').val('');
          $('input[name=txt_event_user_position]').val('');
          $('input[name=txt_event_user_acquisition_channel]').val('');
          $('input[name=txt_event_user_seniority]').val('');
          $('#event-registration-form').hide();
          $('#event-registration-success').show();
          $('#event-registration-alert').hide();
          history.pushState({ page: 'thank-you' }, '', '/' + txt_company_special_event_code + '/thank-you');
          //Just need to add the same code from the event video in admin but add an 'margin-top:2em;' to the style of the div
          $('#event-video')[0].innerHTML = '<div class="embed-responsive special-event-video-container" style="margin-top:2em; height:auto; align-items:center; flex-direction:column; max-height:1000vh;"><iframe allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen="" frameborder="0" height="315" id="special-event-video" src="https://www.youtube.com/embed/uX8RJXA6hTU" style="position:static;" title="YouTube video player" width="560"></iframe></div>;'
          $('#event-video')[0].scrollIntoView({block: "center", behavior: "smooth"});
        },
        error: function(resp){
          var errors = jQuery.parseJSON(resp.responseText).errors;
          $('#btn_event_user_submit').removeAttr('disabled');
          $('#event-registration-alert').show();
          $("label[for='event-registration-error']").html(errors);
        }
      });
    });
});
