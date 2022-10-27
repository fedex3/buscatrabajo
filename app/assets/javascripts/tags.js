$(function(){ // document ready

    //$('[data-toggle="tooltip"]').tooltip();
    //no inicializo porque en la barra qe se mueve se rompe por el alto

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
    });

});