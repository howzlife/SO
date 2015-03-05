$(function() {
	$('.purchaseorder-vendor .vendor-select').on('change','select',function() {
		if ($(this).val() != "") {
        	var vendor = $(this);
        	console.log("/vendors/" + vendor.val() + ".json");
			$.get( "/vendors/" + vendor.val() + ".json", function( data ) {
				$('.purchaseorder-vendor .vendor-select .vendor-details').empty().append(data.name +'<br>').show();
				if (data.contact != "") {
					$('.purchaseorder-vendor .vendor-select .vendor-details').append('Attention: '+data.contact +'<br>');
				}
				if (data.email != "") {
					$('.purchaseorder-vendor .vendor-select .vendor-details').append(data.email);
					$('.buttons .btn-email').show();
				} else {
					$('.buttons .btn-email').hide();
				}
				$('.vendor-change .small-btn').show();
				vendor.hide();
			});
		}
	});
    $('.purchaseorder-vendor .vendor-select').on('click', '.small-btn', function() {
        $('.purchaseorder-vendor .vendor-select select').show();
        $('.purchaseorder-vendor .vendor-select .vendor-details').hide();
    });

	var formChanged = false;
	$('.form-inputs input').each(function () {
		$(this).data('data-initial-value', $(this).val());
	});

	$('.form-inputs input').keypress(function() {
		if (!formChanged) {
			$('.page-header .btn-save').addClass('btn-primary');
			formChanged = true;
		}
	});

	$('.purchaseorder-deliverto .deliverto-select').on('change','select',function() {
		if ($(this).val() != "") {
        	var address = $(this);
			$.get( "/addresses/" + address.val() + ".json", function( data ) {
				$('.purchaseorder-deliverto .deliverto-select .deliverto-details').html(data.name +'<br>'+ data.address.address_line_1 +', '+ data.address.address_line_2 +'<br>'+ data.address.city +', '+ data.address.state +', '+ data.address.zip +'<br>Tel. '+ data.telephone).show();
				$('.purchaseorder-deliverto .deliverto-agent').html(data.agent);
				$('.deliverto-change .small-btn').show();
				address.hide();
			});
		}
	});
	
	if ($('form').hasClass('edit_purchase_order')) {
		$('.deliverto-change .small-btn, .vendor-change .small-btn').show();
        $('.purchaseorder-vendor .vendor-select select, .purchaseorder-deliverto .deliverto-select select').hide();
	}

    $('.purchaseorder-deliverto .deliverto-select').on('click', '.small-btn', function() {
        $('.purchaseorder-deliverto .deliverto-select select').show();
        $('.purchaseorder-deliverto .deliverto-change .small-btn, .purchaseorder-deliverto .deliverto-select .deliverto-details').hide();
    });

	$('.purchaseorder .purchaseorder-input textarea').css('overflow', 'hidden').autogrow();
	$('.buttons .btn-email').hide();

	$('.buttons').on('click','.btn.email', function(event) {
		$('.buttons .btn').hide();
		$('.buttons').append('<div class="loading" />');
	});

    $('.buttons').on('click', '.edit-print', function(event) {
    	if ( $("#purchase_order_description").val() ) {

    		form = $(this).closest('form');
	    	window.print();

    	} else {
    		alert("Description field cannot be empty");
    		event.preventDefault();
    	}
    	
    });

    $('.buttons').on('click', '.show-print', function(event) {

		form = $(this).closest('form');
			window.print();		
    		var payload = form.serialize();
    		$.post( form.attr('action'), payload, function( data ) {
    		});

    	
    });
    
    if ($('p.notice').length) {
    	$('p.notice').delay( 2750 ).fadeOut(250);
    }
    
    $('.sortable').tablesorter();


	$('.phone input').formatter({
	  'pattern': '({{999}}) {{999}}-{{9999}}'
	});

	var currReqObj = null;
    var searchTimeoutThrottle = 500;
    var searchTimeoutID = -1;
	$('.search .search-query').bind('keyup change', function(){
		var results = false;
        if($(this).val() != $(this).data('oldval')) {
        	$(this).data('oldval', $(this).val());
        	if(currReqObj != null) currReqObj.abort();
        	 clearTimeout(searchTimeoutID);
        	 var term = $(this).val();
        	 searchTimeoutID = setTimeout(function(){
				currReqObj = $.get( "/purchase_orders.json?q=" + term, function( data ) {
					currReqObj = null;
					if (data.length == 0) {
						$('#results-popup .purchase-orders').hide();
					} else {
						results = true;
						$('#results-popup, #results-popup .purchase-orders').show();
						$('#results-popup .purchase-orders .results, #results-popup .no-results').empty();
						$.each(data, function(index, item) {
							var url = item.url.slice(0, -5);
							$('#results-popup .purchase-orders .results').append('<div class="row"><a href="' + url + '">' + item.number + '</a></div>');
						});
					}
				});
				currReqObj = $.get( "/vendors.json?q=" + term, function( data ) {
					currReqObj = null;
					if (data.length == 0) {
						$('#results-popup .vendors').hide();
					} else {
						results = true;
						$('#results-popup, #results-popup .vendors').show();
						$('#results-popup .vendors .results, #results-popup .no-results').empty();
						$.each(data, function(index, item) {
							var url = "/edit" + item.url.slice(0, -5);
							$('#results-popup .vendors .results').append('<div class="row"><a href="' + url + '">' + item.name + '</a></div>');
						});
					}
				});
				if (!results) {
					$('#results-popup').show();
					$('#results-popup .purchase-orders, #results-popup .vendors').hide();
					$('#results-popup .no-results').html('No results found.');
				}
            }, searchTimeoutThrottle);
        }
    }).attr('autocomplete', 'off').data('oldval', '');

	$('.search-area .search-query').bind('keyup change', function(){
	    var searchAction = $('.search-area .search-query').parent().attr('action').substring(1, $('.search-area .search-query').parent().attr('action').length);
	    console.log(searchAction);
        // only search if search string has changed
        if($(this).val() != $(this).data('oldval')) {
        	$(this).data('oldval', $(this).val());
        	if(currReqObj != null) currReqObj.abort();
        	 clearTimeout(searchTimeoutID);
        	 var term = $(this).val();
        	 searchTimeoutID = setTimeout(function(){
				 currReqObj = $.get( "/" + searchAction + ".json?q=" + term, function( data ) {
					currReqObj = null;
					if (data.length == 0) {
						$('#searchable-table').hide();
						if (!$('#searchable-table-text').length) {
							if (searchAction == "purchase_orders") {
								$('#searchable-table').parent().append('<div id="searchable-table-text"><h3>Could not find any purchase orders</h3><p>Try changing the search term</p></div>');
							} else {
								$('#searchable-table').parent().append('<div id="searchable-table-text"><h3>Could not find any vendors</h3><p>Try changing the search term</p></div>');
							}
						}
						$('#searchable-table-text').show();
					} else {
						$('#searchable-table').show();
						$('#searchable-table-text').hide();
						$('#searchable-table tbody').empty();
						$.each(data, function(index, item) {
							console.log(item);
							var url = item.url.slice(0, -5);
							var label = item.tags != null ? item.tags : '';
							if (searchAction == "purchase_orders") {
								$('#searchable-table tbody').append('<tr><td><a href="' + url + '">' + item.number + '</a></td><td>' +  $.format.date(item.date, "MMMM D, yyyy") + '</td><td>' + item.vendor.name + '</td><td>' + label + '</td><td><span class="label status-' + item.status + '">' + item.status + '</span></td></tr>');
							} else {
								url += "/edit";
								$('#searchable-table tbody').append('<tr><td><a href="' + url + '">' + item.name + '</a></td><td>' + item.email + '</td><td>' + item.contact + '</td><td>' + item.telephone + '</td><td>' + item.fax + '</td></tr>');
							}
						});
						$('.sortable').trigger("update");
					}
				});
            }, searchTimeoutThrottle);
        }
    }).attr('autocomplete', 'off').data('oldval', '');
    
});

$(document).mouseup(function (e)
{
    var container = $("#results-popup");

    if (!container.is(e.target) // if the target of the click isn't the container...
        && container.has(e.target).length === 0) // ... nor a descendant of the container
    {
        container.hide();
    }
});