$(function(){
  $(".admin_companies").each(function(e) {
    $('body').on('cocoon:after-insert', function(e, addedPartial){
      addedPartial.find('.company_story_focus').focus();
      addedPartial.find('.company_speech_focus').focus();
      addedPartial.find('.company_video_focus').focus();
      addedPartial.find('.company_photo_focus').focus();
    });
  }); 
}); 