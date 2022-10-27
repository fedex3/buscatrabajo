//= require bootstrap-tagsinput
//= require bootstrap3-typeahead
//= require jquery.remotipart
//=require infinite_scrolling.js 
//in order to load more jobs only when user scrolls down enough
$(function(){ // document ready
  $(".jobs").each(function(e) {
    //$('[data-toggle="tooltip"]').tooltip();
    //no inicializo porque en la barra qe se mueve se rompe por el alto

    if ($('#job-social-bar').length) { // make sure "#sticky" element exists
      var stickyTop = $('#job-social-bar').offset().top; // returns number
      var stickyHeight = $('#job-social-bar').height();

      $(window).scroll(function(){ // scroll event

        if ($('#job_social_bar_top').length){
          limit = $('#job_social_bar_top').offset().top - 20;
        }

        var windowTop = $(window).scrollTop(); // returns number

        if (windowTop + stickyTop > limit) {
        	//alert('window: ' + windowTop);
        	//alert('sum: ' + (windowTop + stickyTop));
        	var diff = limit - windowTop;
        	if ($('#job-social-bar-nav').hasClass('navbar-fixed-bottom')){
        		$('#job-social-bar-nav').removeClass('navbar-fixed-bottom');
        	}
        	if (!$('#job-social-bar-nav').hasClass('navbar-static-bottom')){
        		$('#job-social-bar-nav').addClass('navbar-static-bottom');
        	}
        } else {
        	if (!$('#job-social-bar-nav').hasClass('navbar-fixed-bottom')){
        		$('#job-social-bar-nav').addClass('navbar-fixed-bottom');
        	}
        	if ($('#job-social-bar-nav').hasClass('navbar-static-bottom')){
        		$('#job-social-bar-nav').removeClass('navbar-static-bottom');
        	}
        }

        if ($(document).scrollTop() > 50) {
          if ($('#navbar-book-mentors').hasClass('navbar-book-mentor-low-zindex')){
            $('#navbar-book-mentors').fadeIn(600);
            $('#navbar-book-mentors').addClass('navbar-book-mentor-high-zindex');
            $('#navbar-book-mentors').removeClass('navbar-book-mentor-low-zindex');
          }
        } else {

          if ($('#navbar-book-mentors').hasClass('navbar-book-mentor-high-zindex')){
            $('#navbar-book-mentors').hide();
            $('#navbar-book-mentors').removeClass('navbar-book-mentor-high-zindex');
            $('#navbar-book-mentors').addClass('navbar-book-mentor-low-zindex');
          }
        }

      });
    }
    /*Job Favorite POST*/
    $('a[name="btn_job_favorite"]').on("click",function(event){
      if (!($('a[name="btn_job_favorite"]').hasClass('disabled'))) {
        $('a[name="btn_job_favorite"]').addClass('disabled', '');
        company_id = $('input[name=hdn_company_id]').val();
        job_id = $('input[name=hdn_job_id]').val();
        var txt_locale = $('#locale')[0].innerHTML;
        $.ajax({
          type: "POST",
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          url: "/" + txt_locale + "/companies/" + company_id + "/jobs/" + job_id + "/job_favorites",
          success: function(){
            if ($('#btn_favorite_heart').hasClass('fa-heart-favorite')){
              $('#btn_favorite_heart').removeClass('fa-heart-favorite');
            } else{
              $('#btn_favorite_heart').addClass('fa-heart-favorite', '');
            }
            $('a[name="btn_job_favorite"]').removeClass('disabled');
          },
          error: function(resp){
            var errors = $.parseJSON(resp.responseText).errors;
            //$('a[name="btn_job_favorite"]').removeClass('disabled');
           }
        });
      }
    });

    $("#job_apply_now").click(function() {
       $("body, html").animate({
        scrollTop: $(".job-application-container").offset().top - 0
      }, 600);
    });

    $("#job_application_new_cv").on("click",function(){
      $('#job_application_user_cv').show();
    });


    $("#new_job_application").on("ajax:success", function(e, data, status, xhr) {
//      gtag_report_conversion();
    });

    $("#new_job_application").on("ajax:error", function(e, xhr, status, error) {
      var errors = $.parseJSON(xhr.responseText).errors;
      $('#job-application-alert').show();
      $("label[for='job-application-error']").html(errors);
    });

    $("#new_job_application").on("ajax:remotipartComplete", function(e, data){
    });

    $("#new_job_application").bind("ajax:success", function(){
      $("#job_apply_now").hide();
      $("#job_have_apply").show();
    });


    $(document).on("click", "#btn_job_application_soft_submit", function(e) {
      $('#btn_job_application_soft_submit').attr('disabled', '');
      var txt_locale = $('#locale')[0].innerHTML;
      var txt_newsletter_email = $("#txt_newsletter_email").val();
      var txt_newsletter_country = $("#txt_newsletter_country").val();
      var txt_analytics_client_id = $("#analytics_client_id").val();
      var txt_job_application_source = $("#txt_job_application_source").val();
      var txt_job_application_medium = $("#txt_job_application_medium").val();
      var txt_job_application_campaign = $("#txt_job_application_campaign").val();
      var txt_job_application_term = $("#txt_job_application_term").val();
      var select_user_country = $("#select_user_country").val();
      var txt_user_password = $("#txt_user_password").val();
      var txt_user_name = $("#txt_user_name").val();
      var company_id = $("#hdn_company_id").val();
      var job_id = $("#hdn_job_id").val();
      $.ajax({
        type: "POST",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/" + txt_locale + "/companies/" + company_id + '/jobs/' + job_id + '/job_applications',
        dataType: "json",
        data: { job_application: {
          name: txt_user_name,
          email: txt_newsletter_email,
          password: txt_user_password,
          country: select_user_country,
          source: txt_job_application_source,
          medium: txt_job_application_medium,
          campaign: txt_job_application_campaign,
          term: txt_job_application_term
          } ,
          cid: txt_analytics_client_id  },
        success: function(data, resp){
          $('input[name=txt_newsletter_email]').val('');
          $("#modalJobApplicationSoft").modal('hide');
          redirect_url = data.redirect_url;
          window.location.href = redirect_url;
        },
        error: function(resp){
          var errors = $.parseJSON(resp.responseText).errors;
          $('#btn_job_application_soft_submit').removeAttr('disabled');
          $('#job-application-soft-alert').show();
          $("label[for='job-application-soft-error']").html(errors);
        }
      });
    });
  });
});

$(document).ready(function() {
  // Load the js only for form view where the field is defined
  if($('#skills').val() != undefined){
    $('#skills').tagsinput({
      typeahead: {
        autoSelect: false,
        source: function(query) {
          return $.get('/jobs_skills?listable=true');
        }
      },
    });
    $('#skills').on('itemAdded', function(event) {
      setTimeout(function() {
      $('.bootstrap-tagsinput :input').val('');
      }, 0);
    });
  }
});
