// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery3
//= require jquery_ujs
//= require jquery-ui/widgets/sortable
//= require bootstrap-datepicker/core
//= require popper
//= require bootstrap
//= require wice_grid
//= require_directory .

WiceGridProcessor.prototype.reset = function() {
  return this.visit(this.baseRequestForFilter + "?reset_grid=true");
  // TODO: chequear esto, porque le agrega infinitas veces "?reset_grid=true" a la URL
};

$(document).ready(function(){
  if (typeof(WiceGridProcessor) != "undefined"){
   if($( window ).width() < 500)
    {
      var responsive_titles=$('.wice-grid .wice-grid-title-row th').map(function(t) { return $(this).text()})
      $('.wice-grid .wg-filter-row th').each(function(idx) { $(this).prepend(responsive_titles[idx]) });
    }
  }

  $('.custom-file-input').on('change',function(){
    //get the file name
    var fileName = $(this).val().split('\\');
    fileName = fileName[fileName.length - 1];
    //replace the "Choose a file" label
    $(this).next('.custom-file-label').html(fileName);
  })
});

$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})
