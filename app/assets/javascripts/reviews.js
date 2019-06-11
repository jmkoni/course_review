// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready( function () {
  var table = $('#reviews_index').DataTable();
  $("#reviews_index tfoot th").each( function (i) {
    var title = $('#reviews_index thead th').eq( $(this).index() ).text();
    $(this).html( '<input type="text" placeholder="Search" data-index="'+i+'" />' );
  } );
  $( table.table().container() ).on( 'keyup', 'tfoot input', function () {
    table
      .column( $(this).data('index') )
      .search( this.value )
      .draw();
  } );
} );