//=require infinite_scrolling.js
//in order to load more companies only when user scrolls down enough

function replaceThumbforYoutubeVideo(web,element,videoid){
  if (web=="youtube"){
    jQuery(element).replaceWith("<div class='embed-responsive embed-responsive-4by3'><iframe src='https://www.youtube.com/embed/"+videoid+"?modestbranding=1&rel=0&autoplay=1&controls=1&showinfo=1?ecver=1' frameborder='0' allowfullscreen></iframe></div>");
  }
}

$(function(){ // document ready
  $(".companies").each(function(e) {
    //$('[data-toggle="tooltip"]').tooltip();
    //no inicializo porque en la barra qe se mueve se rompe por el alto
    $(".multioffice_body").click(function() {
      $("body, html").animate({ 
        scrollTop: $("#multioffice_body_menu").offset().top - 120
      }, 600);
      $("#multioffice_subheader_menu li").removeClass("active");
      $("#multioffice_subheader_" + $(this).attr("data-id")).addClass("active");
    });    

    $(".multioffice_subheader").click(function() {
      $("body, html").animate({ 
        scrollTop: $("#multioffice_body_menu").offset().top - 120
      }, 600);
      $("#multioffice_body_menu li").removeClass("active");
      $("#multioffice_subheader_menu li").removeClass("active");
      $("#multioffice_body_" + $(this).attr("data-id")).addClass("active");
    });    

    if ($('#company-social-bar').length) { // make sure "#sticky" element exists
      var stickyTop = $('#company-social-bar').offset().top; // returns number
      var stickyHeight = $('#company-social-bar').height();

      $(window).scroll(function(){ // scroll event

        /*Social bar*/
        //var limit = $('#other-companies-div').offset().top -  stickyHeight - 20;
        var limit = 0
        if ($('#company_social_bar_top').length){
          limit = $('#company_social_bar_top').offset().top - 20;
        }

        var windowTop = $(window).scrollTop(); // returns number

        if (windowTop + stickyTop > limit) {
        	//alert('window: ' + windowTop);
        	//alert('sticyk top: ' + stickyTop);
        	//alert('sum: ' + (windowTop + stickyTop));
        	var diff = limit - windowTop;
        	if ($('#company-social-bar-nav').hasClass('navbar-fixed-bottom')){
        		$('#company-social-bar-nav').removeClass('navbar-fixed-bottom');
        	}
        	if (!$('#company-social-bar-nav').hasClass('navbar-static-bottom')){
        		$('#company-social-bar-nav').addClass('navbar-static-bottom');
        	}
        } else {
        	if (!$('#company-social-bar-nav').hasClass('navbar-fixed-bottom')){
        		$('#company-social-bar-nav').addClass('navbar-fixed-bottom');
        	}
        	if ($('#company-social-bar-nav').hasClass('navbar-static-bottom')){
        		$('#company-social-bar-nav').removeClass('navbar-static-bottom');
        	}
        }
      });
    }
    /*Company Favorite POST*/
    $('a[name="btn_company_favorite"]').on("click",function(event){
      if (!($('a[name="btn_company_favorite"]').hasClass('disabled'))) {
        $('a[name="btn_company_favorite"]').addClass('disabled', '');
        if($('a[name="btn_company_favorite"]').attr("data-color")== "green"){
          $('a[name="btn_company_favorite"] i')[0].style.color = "#2E2B83";
          $('a[name="btn_company_favorite"]').attr("data-color","purple");
          alert('Empresa agregada a favoritos');
        }
        else{
          $('a[name="btn_company_favorite"] i')[0].style.color = "#2DB08C";
          $('a[name="btn_company_favorite"]').attr("data-color","green");
          alert('Empresa removida de favoritos');
        }
        company_id = $('input[name=hdn_company_id]').val();
        var txt_locale = $('#locale')[0].innerHTML;
        $.ajax({
          type: "POST",
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          url: "/" + txt_locale + "/companies/" + company_id + "/company_favorites",
          success: function(){
            if ($('#btn_favorite_heart').hasClass('fa-heart-favorite')){
              $('#btn_favorite_heart').removeClass('fa-heart-favorite');  
            } else{
              $('#btn_favorite_heart').addClass('fa-heart-favorite', '');
            }
            $('a[name="btn_company_favorite"]').removeClass('disabled');
          },
          error: function(resp){
            var errors = $.parseJSON(resp.responseText).errors;
            $('a[name="btn_company_favorite"]').removeClass('disabled');
          }
        });
      }
    });

    $('#companies-whatsapp-button').on("click",function(event){
      company_id = $('input[name=hdn_company_id]').val();
      var txt_locale = $('#locale')[0].innerHTML;
      $.ajax({
        type: "POST",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/" + txt_locale + "/empresas/" + company_id + "/statistics",
        data:{
          button_clicked: 'whatsapp_button',
        }
      });
    });
    $('#companies-email-button').on("click",function(event){
      company_id = $('input[name=hdn_company_id]').val();
      var txt_locale = $('#locale')[0].innerHTML;
      $.ajax({
        type: "POST",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/" + txt_locale + "/empresas/" + company_id + "/statistics",
        data:{
          button_clicked: 'email_button',
        }
      });
    });
    $('#companies-external-jobs-button').on("click",function(event){
      company_id = $('input[name=hdn_company_id]').val();
      var txt_locale = $('#locale')[0].innerHTML;
      $.ajax({
        type: "POST",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/" + txt_locale + "/empresas/" + company_id + "/statistics",
        data:{
          button_clicked: 'jobs_button',
        }
      });
    });
    $('#companies-internal-jobs-button').on("click",function(event){
      company_id = $('input[name=hdn_company_id]').val();
      var txt_locale = $('#locale')[0].innerHTML;
      $.ajax({
        type: "POST",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/" + txt_locale + "/empresas/" + company_id + "/statistics",
        data:{
          button_clicked: 'jobs_button',
        }
      });
    });
  });  
});
