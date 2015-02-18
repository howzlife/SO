# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  subscription.setupForm()
  changecard.updateForm()

subscription =
  setupForm: ->
    $('#new_subscription').submit ->
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number').length
        subscription.processCard()
        false
      else
        true

#For adding a card
  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
      country: $('#country').val()
      address_zip: $('#postal_code').val()
      address_line1: $('#address').val()
      address_city: $('#city').val()
      address_state: $('#state').val()
    Stripe.card.createToken(card, subscription.handleStripeCreateResponse)
  
  handleStripeCreateResponse: (status, response) ->
    if status == 200
      $('#subscription_stripe_card_token').val(response.id)
      $('#new_subscription')[0].submit()
    else
      $('#stripe_error').text(response.error.message)
      $('input[type=submit]').attr('disabled', false)

changecard =
#Update card form -> Update action
  updateForm: ->
    $('#update_card').submit ->
      $('input[type=submit] #update_card' ).attr('disabled', true)
      if $('#card_number').length
        changecard.updateCard()
        false
      else
        true

#For updating a card
  updateCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
      country: $('#country').val()
      address_zip: $('#postal_code').val()
      address_line1: $('#address').val()
      address_city: $('#city').val()
      address_state: $('#state').val()
    Stripe.card.createToken(card, changecard.handleStripeUpdateResponse)

  # handle the stripe response
  handleStripeUpdateResponse: (status, response) ->
    if status == 200
      $('#subscription_stripe_card_token').val(response.id)
      $('#update_card')[0].submit()
    else
      $('#stripe_error').text(response.error.message)
      $('input[type=submit]').attr('disabled', false)
