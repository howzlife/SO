// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .

$(function() {
	$('.purchaseorder-vendor .vendor-select').on('change','select',function() {
		if ($(this).val() != "") {
			var vendor = JSON.parse($(this).val().replace(/'/g, '"'));
        	$(this).hide();
			$('.purchaseorder-vendor .vendor-select .vendor-details').html(vendor.name +'<br>Attention: '+ vendor.contact +'<br>'+ vendor.email).show();
			$('.vendor-change .small-btn').show();
		}
	});
    $('.purchaseorder-vendor .vendor-select').on('click', '.small-btn', function() {
        $('.purchaseorder-vendor .vendor-select select').show();
        $('.purchaseorder-vendor .vendor-change .small-btn, .purchaseorder-vendor .vendor-select .vendor-details').hide();
    });
	$('.purchaseorder .purchaseorder-input textarea').css('overflow', 'hidden').autogrow();
    $('.buttons').on('click', '.print', function() {
		window.print();
    });
    
    if ($('p.notice').length) {
    	$('p.notice').delay( 3000 ).fadeOut(100);
    }
    
    $('.sortable').tablesorter();

	var currReqObj = null;
    var searchTimeoutThrottle = 500;
    var searchTimeoutID = -1;
	$('.search-area .search-query').bind('keyup change', function(){
        //Only search if search string longer than 2, and it has changed
        if($(this).val().length > 2 && $(this).val() != $(this).data('oldval')) {
        	$(this).data('oldval', $(this).val());
        	if(currReqObj != null) currReqObj.abort();
        	 clearTimeout(searchTimeoutID);
        	 var term = $(this).val();
        	 searchTimeoutID = setTimeout(function(){
				 currReqObj = $.get( "/purchase_orders.json?q=" + term, function( data ) {
					currReqObj = null;
					if(data.length == 0) {
					} else {
						$('#purchase-orders-table tbody').empty();
						$.each(data, function(index, item) {
							var url = item.url.slice(0, -5);
							$('#purchase-orders-table tbody').append('<tr><td><a href="' + url + '">' + item.number + '</a></td><td>' +  $.format.date(item.date, "MMMM D, yyyy") + '</td><td>' + item.vendor.name + '</td><td>' + item.status + '</td></tr>');
						});
						$('.sortable').trigger("update");
					}
				});
            }, searchTimeoutThrottle);
        }
    }).attr('autocomplete', 'off').data('oldval', '');
    
});
