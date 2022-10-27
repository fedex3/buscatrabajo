$(function(){
  $(".admin_questions").each(function(e) {
    $('body').on('cocoon:after-insert', function(e, addedPartial){
      addedPartial.find('.question_option_focus').focus();
    });
  }); 
}); 