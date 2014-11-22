
$(function() {
	$('.purchaseorder-vendor .vendor-select').on('change','select',function() {
		if ($(this).val() != "") {
        	vendor = $(this);
			$.get( "/vendors/" + vendor.val() + ".json", function( data ) {
				$('.purchaseorder-vendor .vendor-select .vendor-details').html(data.name +'<br>Attention: '+ data.contact +'<br>'+ data.email).show();
				$('.vendor-change .small-btn').show();
				vendor.hide();
			});
		}
	});
    $('.purchaseorder-vendor .vendor-select').on('click', '.small-btn', function() {
        $('.purchaseorder-vendor .vendor-select select').show();
        $('.purchaseorder-vendor .vendor-change .small-btn, .purchaseorder-vendor .vendor-select .vendor-details').hide();
    });

	$('.purchaseorder-deliverto .deliverto-select').on('change','select',function() {
		if ($(this).val() != "") {
			var address = JSON.parse($(this).val().replace(/'/g, '"'));
        	$(this).hide();
			$('.purchaseorder-deliverto .deliverto-select .deliverto-details').html(address.name +'<br>'+ address.address +'<br>Attention: '+ address.agent +'<br>'+ address.telephone).show();
			$('.deliverto-change .small-btn').show();
		}
	});
    $('.purchaseorder-deliverto .deliverto-select').on('click', '.small-btn', function() {
        $('.purchaseorder-deliverto .deliverto-select select').show();
        $('.purchaseorder-deliverto .deliverto-change .small-btn, .purchaseorder-deliverto .deliverto-select .deliverto-details').hide();
    });

	$('.purchaseorder .purchaseorder-input textarea').css('overflow', 'hidden').autogrow();
	
		
	
    $('.buttons .form-print').on('click', '.print', function(event) {
    	event.preventDefault();
    	if($(this).closest('form').hasClass('status-complete')) {
    		form = $(this).closest('form');
	    	if(confirm('This will mark the purchase order open. Are you sure?')) {
	    		var payload = form.serialize() + '&status=open';
	    		$.post( form.attr('action'), payload, function( data ) {
					window.print();
	    		});
	    	}
    	} else {
			window.print();
		}
    });
    
    if ($('p.notice').length) {
    	$('p.notice').delay( 3000 ).fadeOut(100);
    }
    
    $('.sortable').tablesorter();

	var currReqObj = null;
    var searchTimeoutThrottle = 500;
    var searchTimeoutID = -1;
	$('.search-area .search-query').bind('keyup change', function(){
        // only search if search string has changed
        if($(this).val() != $(this).data('oldval')) {
        	$(this).data('oldval', $(this).val());
        	if(currReqObj != null) currReqObj.abort();
        	 clearTimeout(searchTimeoutID);
        	 var term = $(this).val();
        	 searchTimeoutID = setTimeout(function(){
				 currReqObj = $.get( "/purchase_orders.json?q=" + term, function( data ) {
					currReqObj = null;
					if(data.length == 0) {
						$('#purchase-orders-table').hide();
						if (!$('#purchase-orders-search').length) {
							$('#purchase-orders-table').parent().append('<div id="purchase-orders-search"><h3>Could not find any purchase orders</h3><p>Try changing the search term</p></div>');
						}
						$('#purchase-orders-search').show();
					} else {
						$('#purchase-orders-table').show();
						$('#purchase-orders-search').hide();
						$('#purchase-orders-table tbody').empty();
						$.each(data, function(index, item) {
							var url = item.url.slice(0, -5);
							$('#purchase-orders-table tbody').append('<tr><td><a href="' + url + '">' + item.number + '</a></td><td>' +  $.format.date(item.date, "MMMM D, yyyy") + '</td><td>' + item.vendor.name + '</td><td><span class="label status-' + item.status + '">' + item.status + '</span></td></tr>');
						});
						$('.sortable').trigger("update");
					}
				});
            }, searchTimeoutThrottle);
        }
    }).attr('autocomplete', 'off').data('oldval', '');
    
});
