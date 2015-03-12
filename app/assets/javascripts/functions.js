$(function() {

	var formChanged = false;
	$('.form-inputs input').each(function () {
		$(this).data('data-initial-value', $(this).val());
	});

	$('.form-inputs input, #purchase_order_description').keypress(function() {
		console.log('x');
		if (!formChanged) {
			$('.page-header .btn-save').addClass('btn-primary');
			formChanged = true;
		}
	});


	$('.purchaseorder .purchaseorder-input textarea').css('overflow', 'hidden').autogrow();

    $('.buttons').on('click', '.edit-print', function(event) {
		form = $(this).closest('form');
		window.print();
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
    var searchTimeoutThrottle = 100;
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
								$('#searchable-table tbody').append('<tr><td><a href="' + url + '" class="inverted-link">' + item.number + '</a></td><td>' +  $.format.date(item.date, "MMMM D, yyyy") + '</td><td>' + item.vendor.name + '</td><td>' + label + '</td><td><span class="label status-' + item.status + '">' + item.status + '</span></td></tr>');
							} else {
								url += "/edit";
								$('#searchable-table tbody').append('<tr><td><a href="' + url + '" class="inverted-link">' + item.name + '</a></td><td>' + item.email + '</td><td>' + item.contact + '</td><td>' + item.telephone + '</td><td>' + item.fax + '</td></tr>');
							}
						});
						$('.sortable').trigger("update");
					}
				});
            }, searchTimeoutThrottle);
        }
    }).attr('autocomplete', 'off').data('oldval', '');

	$('.purchaseorder-vendor .vendor-select-input').bind('keyup change', function(){
        if($(this).val() != $(this).data('oldval') && $(this).val() != "") {
        	$(this).data('oldval', $(this).val());
        	if(currReqObj != null) currReqObj.abort();
        	 clearTimeout(searchTimeoutID);
        	 var term = $(this).val();
        	 searchTimeoutID = setTimeout(function(){
				 currReqObj = $.get( "/vendors.json?q=" + term, function( data ) {
					currReqObj = null;
					$('.purchaseorder-vendor .vendor-select-list').show();
					$('.purchaseorder-vendor .vendor-select-list .list-body').empty();
					if (data.length > 0) {
						$.each(data, function(index, item) {
							$('.purchaseorder-vendor .vendor-select-list .list-body').append('<div class="vendor-name" data-id="' + item.id + '">' + item.name + '</div>');
						});
					} else {
						$('.purchaseorder-vendor .vendor-select-list .list-body').append('<div class="empty">No results found.</div>');
					}
				});
            }, searchTimeoutThrottle);
        }
		if($(this).val() == "") {
			$('.purchaseorder-vendor .vendor-select-list').hide();
		}
    }).attr('autocomplete', 'off').data('oldval', '');

	$('.purchaseorder-deliverto .deliverto-select-input').bind('keyup change', function(){
        if($(this).val() != $(this).data('oldval') && $(this).val() != "") {
        	$(this).data('oldval', $(this).val());
        	if(currReqObj != null) currReqObj.abort();
        	 clearTimeout(searchTimeoutID);
        	 var term = $(this).val();
        	 searchTimeoutID = setTimeout(function(){
				 currReqObj = $.get( "/addresses.json?q=" + term, function( data ) {
					currReqObj = null;
					$('.purchaseorder-deliverto .deliverto-select-list').show();
					$('.purchaseorder-deliverto .deliverto-select-list .list-body').empty();
					if (data.length > 0) {
						$.each(data, function(index, item) {
							$('.purchaseorder-deliverto .deliverto-select-list .list-body').append('<div class="deliverto-name" data-id="' + item.id + '">' + item.name + '</div>');
						});
					} else {
						$('.purchaseorder-deliverto .deliverto-select-list .list-body').append('<div class="empty">No results found.</div>');
					}
				});
            }, searchTimeoutThrottle);
        }
		if($(this).val() == "") {
			$('.purchaseorder-deliverto .deliverto-select-list').hide();
		}
    }).attr('autocomplete', 'off').data('oldval', '');



	$('.purchaseorder-vendor .deliverto-select-list').on('click', '.vendor-name', function(event) {
		$('#purchase_order_address option[value="' + $(this).data('id') + '"]').prop('selected', true);
	});
	
	$('.purchaseorder-vendor .vendor-select-list').on('click', '.vendor-name', function(event) {
		var vendorEmail = false;
		var vendorFax = false;

		$('#purchase_order_vendor option[value="' + $(this).data('id') + '"]').prop('selected', true);
		$('.purchaseorder-vendor .vendor-select-list, .purchaseorder-vendor .vendor-select-input').hide();
		$.get( "/vendors/"+ $(this).data('id') +".json", function( data ) {
			$('.purchaseorder-vendor .vendor-select-text .vendor-selected').empty();
			$.each(data, function(index, name) {
				if (index != "id") {
					if (name != "") {
						if (index == "name") {
							$('.purchaseorder-vendor .vendor-select-text .vendor-selected').append('<div class="' + index + '">' + name + '</div>').show();
						} else {
							var label = index;
							if (index == "contact") {
								label = "Attn";
							} else if (index == "telephone") {
								label = "Tel";
							} else if (index == "fax") {
								label = "Fax";
							} else if (index == "email") {
								label = "Email";
							}
							$('.purchaseorder-vendor .vendor-select-text .vendor-selected').append('<div class="' + index + '">' + label + ': ' + name + '</div>').show();
						}						
						if (index == "email") {
							vendorEmail = true;
						} else if (index == "fax") {
							vendorFax = true;
						}
					}
				}
			});
			$('.purchaseorder-vendor .vendor-select-text .vendor-selected').append('<span class="change">&times;</span>');
			if (vendorFax) {
				$('.buttons .btn-fax').prop("disabled", false);
			}
			if (vendorEmail) {
				$('.buttons .btn-email').prop("disabled", false);
			}
		});
	});

	$('.purchaseorder-vendor .vendor-selected').on('click', '.change', function(event) {
		$('.purchaseorder-vendor .vendor-select-text .vendor-selected').empty().hide();
		$('.purchaseorder-vendor .vendor-select-input').show().val('');
		$('.buttons .btn-fax, .buttons .btn-email').prop("disabled", "disabled");
	});

});

$(document).mouseup(function (e) {
    var container = $("#results-popup, .purchaseorder-vendor .vendor-select-list");

    if (!container.is(e.target) // if the target of the click isn't the container...
        && container.has(e.target).length === 0) // ... nor a descendant of the container
    {
        container.hide();
    }
});
