$(function() {

	var currReqObj = null;
    var searchTimeoutThrottle = 100; // speed of search
    var searchTimeoutID = -1;

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
    
    if ($('.notice').length) {
    	$('.notice').delay( 2750 ).fadeOut(250);
    }
    
    $('.sortable').tablesorter();

	$('.phone input').formatter({
	  'pattern': '({{999}}) {{999}}-{{9999}}'
	});

	$('#tagsinput').tagsinput({
		maxTags: 1
	});

	// sidebar search
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
							$('#results-popup .purchase-orders .results').append('<div class="row"><a href="/purchase_orders/' + item.id + '">' + item.number + '</a></div>');
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
							$('#results-popup .vendors .results').append('<div class="row"><a href="/vendors/' + item.id + '/edit">' + item.name + '</a></div>');
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

	// vendor and purchase order search
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
							if (searchAction == "purchase_orders") {
								var trclass = item.archived ? ' class="archived"' : '';
								var label = item.label != "" ? item.label : '&ndash;';
								$('#searchable-table tbody').append('<tr' + trclass + '><td><a href="/purchase_orders/' + item.id + '" class="inverted-link">' + item.number + '</a></td><td>' +  $.format.date(item.date, "MMMM D, yyyy") + '</td><td>' + item.vendor.name + '</td><td>' + label + '</td><td><span class="label status-' + item.status + '">' + item.status + '</span></td></tr>');
							} else {
								$('#searchable-table tbody').append('<tr><td><a href="/vendors/' + item.id + '/edit" class="inverted-link">' + item.name + '</a></td><td>' + item.email + '</td><td>' + item.contact + '</td><td>' + item.telephone + '</td><td>' + item.fax + '</td></tr>');
							}
						});
						$('.sortable').trigger("update");
					}
				});
            }, searchTimeoutThrottle);
        }
    }).attr('autocomplete', 'off').data('oldval', '');

	// date select datepicker
	$( "#purchase_order_date_required" ).datepicker({dateFormat: 'MM d, yy', dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'], minDate: 0});

	// vendor select autocomplete
	$('.purchaseorder-vendor .dynamic-select-input').autocomplete({
		open: function(event, ui) {
			$('.purchaseorder-vendor .dynamic-select-list').show();
			$(".ui-autocomplete").css({top:"0px",left:"0px",width:"100%"});
		},
		close: function(event, ui) {
			$('.purchaseorder-vendor .dynamic-select-list').hide();
		},
		source: function (request, response) {
			$.getJSON("/vendors.json?q=" + request.term, function (data) {
				response($.map(data, function (key, value) {
					console.log(key.name);
					return {
						label: key.name,
						value: key.id
					};
				}));
			});
		},
		appendTo: '.purchaseorder-vendor .dynamic-select-list .list-body',
		change: function (event, ui) {
			if(!ui.item){
				$(event.target).val("");
			}
		}, 
		focus: function (event, ui) {
			return false;
		},
		select: function(event, ui) {
			$('.purchaseorder-vendor .dynamic-select-list, .purchaseorder-vendor .dynamic-select-input').hide();

			$.get( "/vendors/"+ ui.item.value +".json", function( data ) {
				$('.purchaseorder-vendor .dynamic-select-text .dynamic-selected').empty();
				$.each(data, function(index, name) {
					if (index != "id") {
						if (name != "") {
							if (index == "name") {
								$('.purchaseorder-vendor .dynamic-select-text .dynamic-selected').append('<div class="' + index + '">' + name + '</div>').show();
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
								$('.purchaseorder-vendor .dynamic-select-text .dynamic-selected').append('<div class="' + index + '">' + label + ': ' + name + '</div>').show();
							}						
							if (index == "email") {
								vendorEmail = true;
							} else if (index == "fax") {
								vendorFax = true;
							}
						}
					}
				});
				$('.purchaseorder-vendor .dynamic-select-text .dynamic-selected').append('<span class="change">&times;</span>');
				if (vendorFax) {
					$('.buttons .btn-fax').prop("disabled", false);
				}
				if (vendorEmail) {
					$('.buttons .btn-email').prop("disabled", false);
				}
			});

		},
		minLength: 0,
		delay: 100
	});

	// vendor select change
	$('.purchaseorder-vendor .dynamic-selected').on('click', '.change', function(event) {
		$('.purchaseorder-vendor .dynamic-select-text .dynamic-selected').empty().hide();
		$('.purchaseorder-vendor .dynamic-select-input').show().val('');
		$('.buttons .btn-fax, .buttons .btn-email').prop("disabled", "disabled");
	});

	// deliover to select search
	$('.purchaseorder-deliverto .dynamic-select-input').autocomplete({
		open: function(event, ui) {
			$('.purchaseorder-deliverto .dynamic-select-list').show();
			$(".ui-autocomplete").css({top:"0px",left:"0px",width:"100%"});
		},
		close: function(event, ui) {
			$('.purchaseorder-deliverto .dynamic-select-list').hide();
		},
		source: function (request, response) {
			$.getJSON("/addresses.json?q=" + request.term, function (data) {
				response($.map(data, function (key, value) {
					console.log(key.name);
					return {
						label: key.name,
						value: key.id
					};
				}));
			});
		},
		appendTo: '.purchaseorder-deliverto .dynamic-select-list .list-body',
		change: function (event, ui) {
			if(!ui.item){
				$(event.target).val("");
			}
		}, 
		focus: function (event, ui) {
			return false;
		},
		select: function(event, ui) {

			$('.purchaseorder-deliverto .dynamic-select-list, .purchaseorder-deliverto .dynamic-select-input').hide();
			$.get( "/addresses/"+ ui.item.value +".json", function( data ) {
				$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').empty().show();
				console.log(data);
				$.each(data, function(index, name) {
					if (index != "id") {
						if (name != "") {
							if (index == "name") {
								$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').append('<div class="' + index + '">' + name + '</div>');
							} else if (index == "address") {
								$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').append('<div class="' + index + '">' + name.address_line_1 +', '+ name.address_line_2 +'<br>'+ name.city +', '+ name.state +', '+ name.zip + '</div>');
							} else {
								var label = index;
								if (index == "agent") {
									label = "Attn"
								} else if (label == "telephone") {
									label = "Tel"
								} else if (index == "fax") {
									label = "Fax";
								}
								$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').append('<div class="' + index + '">' + label + ': ' + name + '</div>').show();
							}
						}
					}
				});
				$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').append('<span class="change">&times;</span>');
			});

		},
		minLength: 0,
		delay: 100
	});

	// deliverto select change
	$('.purchaseorder-deliverto .dynamic-selected').on('click', '.change', function(event) {
		$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').empty().hide();
		$('.purchaseorder-deliverto .dynamic-select-input').show().val('');
	});
	
	
/*	
	$('.purchaseorder-deliverto .dynamic-select-input').bind('keyup change', function(){
        if($(this).val() != $(this).data('oldval') && $(this).val() != "") {
        	$(this).data('oldval', $(this).val());
        	if(currReqObj != null) currReqObj.abort();
        	 clearTimeout(searchTimeoutID);
        	 var term = $(this).val();
        	 searchTimeoutID = setTimeout(function(){
				 currReqObj = $.get( "/addresses.json?q=" + term, function( data ) {
					currReqObj = null;
					$('.purchaseorder-deliverto .dynamic-select-list').show();
					$('.purchaseorder-deliverto .dynamic-select-list .list-body').empty();
					if (data.length > 0) {
						$.each(data, function(index, item) {
							$('.purchaseorder-deliverto .dynamic-select-list .list-body').append('<div class="dynamic-name" data-id="' + item.id + '">' + item.name + '</div>');
						});
					} else {
						$('.purchaseorder-deliverto .dynamic-select-list .list-body').append('<div class="empty">No results found.</div>');
					}
				});
            }, searchTimeoutThrottle);
        }
		if($(this).val() == "") {
			$('.purchaseorder-deliverto .dynamic-select-list').hide();
		}
    }).attr('autocomplete', 'off').data('oldval', '');

	// deliover to select search select
	$('.purchaseorder-deliverto .dynamic-select-list').on('click', '.dynamic-name', function(event) {
		$('#purchase_order_address option[value="' + $(this).data('id') + '"]').prop('selected', true);
		$('.purchaseorder-deliverto .dynamic-select-list, .purchaseorder-deliverto .dynamic-select-input').hide();
		$.get( "/addresses/"+ $(this).data('id') +".json", function( data ) {
			$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').empty().show();
			console.log(data);
			$.each(data, function(index, name) {
				if (index != "id") {
					if (name != "") {
						if (index == "name") {
							$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').append('<div class="' + index + '">' + name + '</div>');
						} else if (index == "address") {
							$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').append('<div class="' + index + '">' + name.address_line_1 +', '+ name.address_line_2 +'<br>'+ name.city +', '+ name.state +', '+ name.zip + '</div>');
						} else {
							var label = index;
							if (index == "agent") {
								label = "Attn"
							} else if (label == "telephone") {
								label = "Tel"
							} else if (index == "fax") {
								label = "Fax";
							}
							$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').append('<div class="' + index + '">' + label + ': ' + name + '</div>').show();
						}
					}
				}
			});
			$('.purchaseorder-deliverto .dynamic-select-text .dynamic-selected').append('<span class="change">&times;</span>');
		});
	});
*/
	
});

$(document).mouseup(function (e) {
    var container = $("#results-popup, .purchaseorder-vendor .vendor-select-list");

    if (!container.is(e.target) // if the target of the click isn't the container...
        && container.has(e.target).length === 0) // ... nor a descendant of the container
    {
        container.hide();
    }
});
