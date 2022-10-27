$(function(){ // document ready
  $(".coaching").each(function(e) {
    $('[data-toggle="tooltip"]').tooltip();
    //$("#coaching_pack_3_button").attr("disabled", true);
    //$("#coaching_pack_3_button").addClass("disabled");
    $("#coaching_pack_tag_more_btn").click(function() {
      $("#coaching_pack_tag_more_btn_div").hide();
      $("#coaching_pack_tag_more").show();
    });

    $("#coaching_pack_tag_less_btn").click(function() {
      $("#coaching_pack_tag_more_btn_div").show();
      $("#coaching_pack_tag_more").hide();
    });


    $("#coaching-portfolio-choose-pack").click(function() {
       $("body, html").animate({ 
        scrollTop: $(".coaching-pack-list").offset().top - 80
      }, 600);
    });

    $("#coaching_video_btn").click(function() {
       $("#coaching_video").show();
       $('body').addClass('modal-open');
    });

    $(document).keyup(function(ev){
        if(ev.keyCode == 27) {
          $("#coaching_video").hide();
          $('body').removeClass('modal-open');
        }
    });

    $("#coaching_video_close").click(function() {
       $("#coaching_video").hide();
       $('body').removeClass('modal-open');
    });
    

    $(".coaching-pack-selector").click(function() {
      //$("#" + $(this).attr("data-id") + "_button").attr("disabled", true);
      //$("#" + $(this).attr("data-id") + "_button").addClass("disabled");
      
      //$("#coaching_pack_" + $(this).attr("data-id")).hide();

      var selected_pack = $(this).attr("data-id");
      var selector = $(this).attr("id");
      
      var listSplit = $(this).attr("data-value").split('-');
      var listPacks = listSplit[0].split(',');
      var listPackTags = listSplit[1].split(',');

      var selector_selected = false;
      if ($("#" + selector).hasClass('active')){
        selector_selected = true
      } 
      for(var i = 0, size = listPackTags.length; i < size ; i++){
        var actual_pack_tag = listPackTags[i];
        $("#coaching_pack_selector_" + actual_pack_tag).removeClass('active');
        if ($("#coaching_pack_selector" + actual_pack_tag).hasClass('active')){
          $("#coaching_pack_selector_" + actual_pack_tag).removeClass('active');
        }
      }
      
      if (!selector_selected){
        $("#" + selector).addClass('active');
        for(var i = 0, size = listPacks.length; i < size ; i++){
          var actual_pack = listPacks[i];
          if(selected_pack != actual_pack){
            $("#coaching_pack_" + actual_pack).hide();           
            $("#coaching_pack_" + actual_pack).removeClass('col-lg-offset-4');
          } else {
            $("#coaching_pack_" + actual_pack).show();
            $("#coaching_pack_" + actual_pack).addClass('col-lg-offset-4');
          }
        }
      } else {
        for(var i = 0, size = listPacks.length; i < size ; i++){
          var actual_pack = listPacks[i];
          $("#coaching_pack_" + actual_pack).show();
          $("#coaching_pack_" + actual_pack).removeClass('col-lg-offset-4');
        }
      }

      $("body, html").animate({ 
        scrollTop: $(".coaching-pack-list").offset().top - 80
      }, 600);
    });    
  });  
});
