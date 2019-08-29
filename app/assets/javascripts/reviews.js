// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on('turbolinks:load', function() {
  $('.hide-column').click(function(e){
    var $btn = $(this);
    var $cell = $btn.closest('th,td')
    var $table = $btn.closest('table')

    // get cell location - https://stackoverflow.com/a/4999018/1366033
    var cellIndex = $cell[0].cellIndex + 1;

    $table.find(".show-column-footer").show()
    $table.find("tbody tr, thead tr")
          .children(":nth-child("+cellIndex+")")
          .hide()
  })

  $(".show-column-footer").click(function(e) {
      var $table = $(this).closest('table')
      $table.find(".show-column-footer").hide()
      $table.find("th, td").show()

  })
})