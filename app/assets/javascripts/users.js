// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready( function () {
  var table = $('#users_index').DataTable();
  $("#users_index tfoot th").each( function (i) {
    var title = $('#users_index thead th').eq( $(this).index() ).text();
    $(this).html( '<input type="text" placeholder="Search '+title+'" data-index="'+i+'" />' );
  } );
  $( table.table().container() ).on( 'keyup', 'tfoot input', function () {
    table
      .column( $(this).data('index') )
      .search( this.value )
      .draw();
  } );
} );