$(function(){ // document ready
  $(".advices").each(function(e) {
    //$('[data-toggle="tooltip"]').tooltip();
    //no inicializo porque en la barra qe se mueve se rompe por el alto
    $('.advice-images-flip').on("click",function(event){
      if($(this).find('.card').hasClass('flip_active')){
        if($(this).find('.card').hasClass('flipped')){
          $(this).find('.card').removeClass('flipped');  
        }else{
          $(this).find('.card').addClass('flipped');  
        }
      }
    });

    $(window).scroll(function(){ // scroll event
      var windowTop = $(window).scrollTop(); // returns number
      var limitSubHeader = 0
      
      if ($('#navbar_subheader_limit').length){
        limitSubHeader = $('#navbar_subheader_limit').offset().top - 40;
      }
      if (windowTop > limitSubHeader) {
        if (!$('#navbar_subheader_advices').hasClass('navbar-subheader-bottom')){
          $('#navbar_subheader_advices').addClass('navbar-subheader-bottom');
        }
        if (!$('#navbar_header').hasClass('navbar-header-small')){
          $('#navbar_header').addClass('navbar-header-small');
        }
      } else {
        if ($('#navbar_subheader_advices').hasClass('navbar-subheader-bottom')){
          $('#navbar_subheader_advices').removeClass('navbar-subheader-bottom');
        }
        if ($('#navbar_header').hasClass('navbar-header-small')){
          $('#navbar_header').addClass('navbar-header-small');
        }
      }

      if ($('#advice_trending_limit_top').length){
        limitTrendingTop = $('#advice_trending_limit_top').offset().top - 40;
      }
      if ($('#advice_trending_limit_bottom').length){
        limitTrendingBottom = $('#advice_trending_limit_bottom').offset().top - $('#advice_trending').height() - 90;
        positionTrendingBottom = $('#advice_trending_limit_bottom').offset().top - $(window).height() -  $('#advice_trending').height() + 90;
        if (positionTrendingBottom< 0){
          positionTrendingBottom = 90; 
        }
      }
      if ($('#advice_trending_limit_top').length && $('#advice_trending_limit_bottom').length){
        if (windowTop > limitTrendingTop) {
          if (windowTop < limitTrendingBottom) {
            if ($('#advice_trending').hasClass('advice-trending-relative')){
              $('#advice_trending').removeClass('advice-trending-relative');
            }
            if ($('#advice_trending').hasClass('advice-trending-bottom')){
              $('#advice_trending').removeClass('advice-trending-bottom');
              $('#advice_trending').css({ top: 0 });
            }
            if (!$('#advice_trending').hasClass('advice-trending-fixed')){
              $('#advice_trending').addClass('advice-trending-fixed');
            }
          }
          else{
            if ($('#advice_trending').hasClass('advice-trending-relative')){
              $('#advice_trending').removeClass('advice-trending-relative');
            }
            if ($('#advice_trending').hasClass('advice-trending-fixed')){
              $('#advice_trending').removeClass('advice-trending-fixed');
            }
            if (!$('#advice_trending').hasClass('advice-trending-bottom')){
              $('#advice_trending').addClass('advice-trending-bottom');
              $('#advice_trending').css({ top: parseInt(positionTrendingBottom) });
            }
          }
        } else {
          if (!$('#advice_trending').hasClass('advice-trending-relative')){
            $('#advice_trending').addClass('advice-trending-relative');
          }
          if ($('#advice_trending').hasClass('advice-trending-bottom')){
              $('#advice_trending').removeClass('advice-trending-bottom');
              $('#advice_trending').css({ top: 0 });
            }
          if ($('#advice_trending').hasClass('advice-trending-fixed')){
            $('#advice_trending').removeClass('advice-trending-fixed');
          }
        }
      }
    });

    if ($('#advice-social-bar').length) { // make sure "#sticky" element exists
      var stickyTop = $('#advice-social-bar').offset().top; // returns number
      var stickyHeight = $('#advice-social-bar').height();

      $(window).scroll(function(){ // scroll event
        /*Subheader bar bar*/

        if ($(document).scrollTop() > 50) {
          if (!$('#advice_next').hasClass('advices-next-container-show')){
            $('#advice_next').addClass('advices-next-container-show');
          }
          
          if ($('#navbar-go-companies').hasClass('navbar-go-companies-low-zindex')){
            $('#navbar-go-companies').fadeIn(600);
            $('#navbar-go-companies').addClass('navbar-go-companies-high-zindex');
            $('#navbar-go-companies').removeClass('navbar-go-companies-low-zindex');
          }
        } else {
          
          if ($('#advice_next').hasClass('advices-next-container-show')){
            $('#advice_next').removeClass('advices-next-container-show');
          }
          if ($('#navbar-go-companies').hasClass('navbar-go-companies-high-zindex')){
            $('#navbar-go-companies').hide();
            $('#navbar-go-companies').removeClass('navbar-go-companies-high-zindex');
            $('#navbar-go-companies').addClass('navbar-go-companies-low-zindex');
          }
        }

        /*Social bar*/
        var limit = 0
        if ($('#advice_social_bar_top').length){
          limit = $('#advice_social_bar_top').offset().top - 20;
        }
        var windowTop = $(window).scrollTop(); // returns number
        //alert('Windiw:' + windowTop);
        //alert('Sticky:' + stickyTop);
        //alert('limit:' + limit);

        if (windowTop + stickyTop > limit) {
        	//alert('window: ' + windowTop);
        	//alert('sticyk top: ' + stickyTop);
        	//alert('sum: ' + (windowTop + stickyTop));
        	var diff = limit - windowTop;
        	if ($('#advice-social-bar-nav').hasClass('navbar-fixed-bottom')){
        		$('#advice-social-bar-nav').removeClass('navbar-fixed-bottom');
        	}
        	if (!$('#advice-social-bar-nav').hasClass('navbar-static-bottom')){
        		$('#advice-social-bar-nav').addClass('navbar-static-bottom');
        	}
        } else {
        	if (!$('#advice-social-bar-nav').hasClass('navbar-fixed-bottom')){
        		$('#advice-social-bar-nav').addClass('navbar-fixed-bottom');
        	}
        	if ($('#advice-social-bar-nav').hasClass('navbar-static-bottom')){
        		$('#advice-social-bar-nav').removeClass('navbar-static-bottom');
        	}
        }

        var limitSubHeader = 0
        if ($('#navbar_subheader_limit').length){
          limitSubHeader = $('#navbar_subheader_limit').offset().top - 40;
        }
        if (windowTop > limitSubHeader) {
          if (!$('#navbar_subheader_advices').hasClass('navbar-subheader-bottom')){
            $('#navbar_subheader_advices').addClass('navbar-subheader-bottom');
          }
          if (!$('#navbar_header').hasClass('navbar-header-small')){
            $('#navbar_header').addClass('navbar-header-small');
          }
        } else {
          if ($('#navbar_subheader_advices').hasClass('navbar-subheader-bottom')){
            $('#navbar_subheader_advices').removeClass('navbar-subheader-bottom');
          }
          if ($('#navbar_header').hasClass('navbar-header-small')){
            $('#navbar_header').addClass('navbar-header-small');
          }
        }

      });
    }
    /*Advice Favorite POST*/
    $('a[name="btn_advice_favorite"]').on("click",function(event){
      if (!($('a[name="btn_advice_favorite"]').hasClass('disabled'))) {
        $('a[name="btn_advice_favorite"]').addClass('disabled', '');
        advice_id = $('input[name=hdn_advice_id]').val();
        var txt_locale = $('#locale')[0].innerHTML;
        $.ajax({
          type: "POST",
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          url: "/" + txt_locale +"/advices/" + advice_id + "/advice_favorites",
          success: function(){
            if ($('#btn_favorite_heart').hasClass('fa-heart-favorite')){
              $('#btn_favorite_heart').removeClass('fa-heart-favorite');  
            } else{
              $('#btn_favorite_heart').addClass('fa-heart-favorite', '');
            }
            $('a[name="btn_advice_favorite"]').removeClass('disabled');
          },
          error: function(resp){
            var errors = $.parseJSON(resp.responseText).errors;
            //$('a[name="btn_advice_favorite"]').removeClass('disabled');
           }
        });
      }
    });
  });  
});
