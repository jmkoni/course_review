// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready( function () {
  var table = $('#schools_index').DataTable();
  $("#schools_index tfoot th").each( function (i) {
    var title = $('#schools_index thead th').eq( $(this).index() ).text();
    $(this).html( '<input type="text" placeholder="Search '+title+'" data-index="'+i+'" />' );
  } );
  $( table.table().container() ).on( 'keyup', 'tfoot input', function () {
    table
      .column( $(this).data('index') )
      .search( this.value )
      .draw();
  } );
} );