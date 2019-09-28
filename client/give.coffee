# # stripe = Stripe('pk_test_CqHTNF8uRfEHz8tB8JyJmSNs')
# # elements = stripe.elements()
#
# Router.route '/give', (->
#     @layout 'layout'
#     @render 'give'
#     ), name:'give'
#
# Template.give.onCreated ->
# 	# Session.set 'giveAmount', ''
#     Template.instance().checkout = StripeCheckout.configure(
#         key: Meteor.settings.public.stripe_publishable
#         image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
#         locale: 'auto'
#         # zipCode: true
#         token: (token) ->
#             # product = Docs.findOne FlowRouter.getParam('doc_id')
#             charge =
#                 amount: product.price*100
#                 currency: 'usd'
#                 source: token.id
#                 description: token.description
#                 # receipt_email: token.email
#             Meteor.call 'STRIPE_single_charge', charge, (error, response) ->
#                 if error then alert error.reason, 'danger'
#                 else alert 'Thanks for your payment.', 'success'
# 	)
#
#
# Template.give.onRendered ->
#     style =
#       base: {
#         color: '#32325d',
#         lineHeight: '18px',
#         fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
#         fontSmoothing: 'antialiased',
#         fontSize: '20px',
#         '::placeholder': {
#           color: '#aab7c4'
#         }
#       },
#       invalid: {
#         color: '#fa755a',
#         iconColor: '#fa755a'
#       }
#     # Create an instance of the card Element.
#     card = elements.create('card', style: style)
#     # Add an instance of the card Element into the `card-element` <div>.
#     card.mount '#card-element'
#     # $('#add_buttons').show()
#     card.addEventListener 'change', (event) ->
#     	displayError = document.getElementById('card-errors')
#     	if event.error
#     		displayError.textContent = event.error.message
#     	else
#     		displayError.textContent = ''
#     	return
#     process = (res)-> Meteor.call 'STRIPE_store_card', res, Meteor.userId(), (err, res)->
#     form = document.getElementById('payment-form')
#     form.addEventListener 'submit', (event) =>
#     	event.preventDefault()
#     	stripe.createToken(card).then Meteor.bindEnvironment((result) =>
#     		if result.error
#     			# Inform the user if there was an error.
#     			errorElement = document.getElementById('card-errors')
#     			errorElement.textContent = result.error.message
#     		else
#     			# Send the token to your server.
#     			process(result.token)
# 		)
#
#
#
#
#
#
# Template.give.helpers
# 	'monthDDL': ->
# 		[
# 			{
# 				text: '01'
# 				value: '01'
# 			}
# 			{
# 				text: '02'
# 				value: '02'
# 			}
# 			{
# 				text: '03'
# 				value: '03'
# 			}
# 			{
# 				text: '04'
# 				value: '04'
# 			}
# 			{
# 				text: '05'
# 				value: '05'
# 			}
# 			{
# 				text: '06'
# 				value: '06'
# 			}
# 			{
# 				text: '07'
# 				value: '07'
# 			}
# 			{
# 				text: '08'
# 				value: '08'
# 			}
# 			{
# 				text: '09'
# 				value: '09'
# 			}
# 			{
# 				text: '10'
# 				value: '10'
# 			}
# 			{
# 				text: '11'
# 				value: '11'
# 			}
# 			{
# 				text: '12'
# 				value: '12'
# 			}
# 		]
# 	'yearDDL': ->
# 		yearDDL = []
# 		i = 0
# 		while i < 10
# 			yearDDL.push
# 				text: moment().year() + i
# 				value: moment().year() + i
# 			i++
# 		yearDDL
# 	isCurrentMonth: (month) ->
# 		if month == moment().month() + 1
# 			'selected'
# 		else
# 			''
# 	getProperUrl: (website) ->
# 		if website
# 			protocol = if website then website.slice(0, 4) else ''
# 			if protocol != 'http'
# 				'http://#website'
# 			else
# 				website
# 		else
# 			''
#
# 	repeating: -> Session.get 'repeating'
# 	token_exists: -> Session.get 'token'
#
#
# Template.give.events
# 	# 'click #scanBtn': ->
# 	# 	CardIO.scan {
# 	# 		'expiry': true
# 	# 		'cvv': true
# 	# 		'zip': false
# 	# 		'suppressManual': false
# 	# 		'suppressConfirm': false
# 	# 		'hideLogo': true
# 	# 		'usePaypalIcon': false
# 	# 	}, ((response) ->
# 	# 		i = 0
# 	# 		len = cardIOResponseFields.length
# 	# 		while i < len
# 	# 			field = cardIOResponseFields[i]
# 	# 			i++
# 	# 		$('#card').val response['card_number']
# 	# 		$('[name="month"]').val response['expiry_month']
# 	# 		$('[name="year"]').val response['expiry_year']
# 	# 		#  $('#exp').val(response['expiry_month']+'/'+response['expiry_year']);
# 	# 		$('#cvc').val response['cvv']
# 	# 		return
# 	# 	), ->
# 	# 		return
# 	# 	return
# 	'click #repeat': ->
# 		Session.set('repeating',!Session.get('repeating'))
# 		# if $('#repeat').is(':checked')
# 		# 	$('#repeat_type').fadeIn()
# 		# else
# 		# 	$('#repeat_type').fadeOut()
# 		# return
# 	'click #fbShhare': (e, t) ->
# 		link = 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href
# 		windowHandle = undefined
# 		if Meteor.isCordova
# 			windowHandle = window.open(link, '_blank', 'location=yes')
# 		else
# 			windowHandle = window.open(null, '', 'height=440,width=640,scrollbars=yes')
# 			windowHandle.location.href = link
# 		return
# 	'click #twShhare': (e, t) ->
# 		link = 'https://twitter.com/intent/tweet?url=' + window.location.href + '&amp;text=Give online through joyful giver&amp;via=Joyful Giver'
# 		windowHandle = undefined
# 		if Meteor.isCordova
# 			windowHandle = window.open(link, '_blank', 'location=yes')
# 		else
# 			windowHandle = window.open(null, '', 'height=440,width=640,scrollbars=yes')
# 			windowHandle.location.href = link
# 		return
# 	'change #amount': ->
# 		Session.set 'giveAmount', $('#amount').val()
# 		$('.total').empty().html ' $' + $('#amount').val()
# 		return
# 	'change #card_select': ->
# 		if $('#card_select').val() == 'NEW'
# 			$('.card_data').show()
# 		else
# 			$('.card_data').hide()
# 		return
#
# 	'click .add_card': ->
#         Template.instance().checkout.open
#             name: 'buy'
#             description: @description
#             amount: 100
# 	'click .print': ->
# 		# Meteor.call 'STRIPE_store_card', result.token, Meteor.userId(), (error, res) ->
#
#
#
#
# 	'click #give': (event, template) ->
# 		`var next`
# 		`var next`
# 		`var next`
# 		`var next`
# 		`var chargeData`
# 		`var next`
# 		`var next`
# 		`var next`
# 		`var next`
# 		$(event.currentTarget).attr 'disabled', true
# 		self = this
# 		if $('#givername').val() != ''
# 			next = true
# 		else
# 			if Meteor.userId()
# 				next = true
# 			else
# 				next = false
# 				FlashMessages.sendError 'Please enter a Name, Donor name is required.'
# 		if Session.get('giveAmount') == ''
# 			$(event.currentTarget).attr 'disabled', false
# 			toastr.error 'Please select give amount'
# 			return false
# 		else if Session.get('giveAmount') < 3
# 			$(event.currentTarget).attr 'disabled', false
# 			toastr.error 'Minimum give amount is $ 3'
# 			return false
# 		if $('#card_select').val() != 'NEW' and $('#card_select').val() != ''
# 			$('.giveFormNoCC').data('bootstrapValidator').validate()
# 		else
# 			$('#giveForm').data('bootstrapValidator').validate()
# 		next = false
# 		if $('#giveForm').data('bootstrapValidator').isValid() and $('#card_select').val() == 'NEW'
# 			# var exp = $('#exp').val().split('/')
# 			chargeData =
# 				card: $('#card').val()
# 				exp_month: $('[name="month"]').val()
# 				exp_year: $('[name="year"]').val()
# 				cvc: $('#cvc').val()
# 			next = true
# 			type = 'new card'
# 		if $('.giveFormNoCC').data('bootstrapValidator').isValid() and $('#card_select').val() != 'NEW' and $('#card_select').val() != ''
# 			chargeData = source: $('#card_select').val()
# 			if $('#card_select').val() != ''
# 				next = true
# 			else
# 				next = false
# 				# $('#giveError').html('<p>Please select a payment card.</p>').fadeIn();
# 				FlashMessages.sendError 'Please select a payment card.'
# 		#alert($('#repeat').is(':checked'))
# 		if $('#repeat').is(':checked') and $('#repeat_type').val() == 0
# 			next = false
# 			FlashMessages.sendError 'How often do you want to repeat this gift?'
# 			# $('#giveError').html('<p>How often do you want to repeat this gift?</p>').fadeIn();
# 		#IF THE FORM IS VALID CONTINUE ON
# 		if next == true
# 			showLoadingMask()
# 			chargeData.church = template.data.church._id
# 			chargeData.amount = parseFloat(Session.get('giveAmount'))
# 			if Meteor.userId()
# 				chargeData.userID = Meteor.userId()
# 				chargeData.customer = Meteor.user().profile.stripe.id
# 			else
# 				chargeData.user = null
# 				chargeData.userID = $('#givername').val()
# 			# if(Session.get('givingCode')){
# 			#     if(Session.get('givingCode')=='name'){    chargeData.givingCode = null;  }
# 			#     else{ chargeData.givingCode = Session.get('givingCode'); }
# 			# }
# 			# else{    chargeData.givingCode = null       }
# 			if self.cid
# 				chargeData.givingCODE = self.cid
# 			else
# 				chargeData.givingCODE = null
# 			if Session.get 'repeating'
# 				chargeData.recurrence = $('#repeat_type').val()
# 				TithPlanObj =
# 					userID: Meteor.userId()
# 					church: chargeData.church
# 					givingCODE: chargeData.givingCODE
# 					amount: chargeData.amount
# 					recurrence: $('#repeat_type').val()
# 					status: 'submitted'
# 				planId = Meteor.call('addTithePlan', TithPlanObj)
# 				#alert(planId)
# 				chargeData.plan = planId
# 			else
# 				chargeData.plan = null
# 			if $('#card_select').val() == 'NEW'
# 				next = false
# 				Stripe.card.createToken {
# 					number: chargeData.card
# 					exp_month: chargeData.exp_month
# 					exp_year: chargeData.exp_year
# 					cvc: chargeData.cvc
# 				}, (status, response) ->
# 					#IF A USER IS PRESENT STORE THE NEWLY TOKENIZED CARD FIRST
# 					if status == 200
# 						if Meteor.userId()
# 							Meteor.call 'STRIPE_store_card', response.id, chargeData.userID, (error, result) ->
# 								if result
# 									chargeData.source = result.id
# 									Meteor.call 'STRIPE_single_charge', chargeData, (error, result) ->
# 										`var result`
# 										if result.error
# 											# $('#giveError').html('<p>'+result.error.message+'</p>').fadeIn();
# 											$(event.currentTarget).attr 'disabled', false
# 											FlashMessages.sendError result.error.message
# 											hideLoadingMask()
# 										else
# 											result = result.result
# 											if result.status == 'succeeded'
# 												id = addTithe(result)
# 												if id
# 													hideLoadingMask()
# 													if $('#email').val() or result.userID
# 														Meteor.call 'sendGiveReciept', $('#email').val(), id
# 													Router.go '/thanks/' + id
# 						else
# 							chargeData.source = response.id
# 							Meteor.call 'STRIPE_single_charge', chargeData, (error, result) ->
# 								`var result`
# 								if result.error
# 									# $('#giveError').html('<p>'+result.error.message+'</p>').fadeIn();
# 									$(event.currentTarget).attr 'disabled', false
# 									FlashMessages.sendError result.error.message
# 									hideLoadingMask()
# 								else
# 									result = result.result
# 									if result.status == 'succeeded'
# 										id = addTithe(result)
# 										if id
# 											hideLoadingMask()
# 											if $('#email').val() or result.userID
# 												Meteor.call 'sendGiveReciept', $('#email').val(), id
# 											Router.go '/thanks/' + id
# 								return
# 					else
# 						# $('#giveError').html(response.error.message).fadeIn();
# 						$(event.currentTarget).attr 'disabled', false
# 						FlashMessages.sendError response.error.message
# 						hideLoadingMask()
# 					return
# 			else if chargeData.source and Meteor.userId()
# 				Meteor.call 'STRIPE_single_charge', chargeData, (error, result) ->
# 					`var result`
# 					if result.error
# 						# $('#giveError').html('<p>'+result.error.message+'</p>').fadeIn();
# 						$(event.currentTarget).attr 'disabled', false
# 						FlashMessages.sendError result.error.message
# 						hideLoadingMask()
# 					else
# 						result = result.result
# 						if result.status == 'succeeded'
# 							id = addTithe(result)
# 							if id
# 								hideLoadingMask()
# 								if $('#email').val() or result.userID
# 									Meteor.call 'sendGiveReciept', $('#email').val(), id
# 								Router.go '/thanks/' + id
# 					return
# 			else
# 				# var exp = $('#exp').val().split('/')
# 				chargeData.card = $('#card').val()
# 				chargeData.exp_month = $('[name="month"]').val()
# 				chargeData.exp_year = $('[name="year"]').val()
# 				chargeData.cvc = $('#cvc').val()
# 				Stripe.card.createToken {
# 					number: chargeData.card
# 					exp_month: chargeData.exp_month
# 					exp_year: chargeData.exp_year
# 					cvc: chargeData.cvc
# 				}, (status, response) ->
# 					#IF A USER IS PRESENT STORE THE NEWLY TOKENIZED CARD FIRST
# 					if status == 200
# 						if Meteor.userId()
# 							Meteor.call 'STRIPE_store_card', response.id, chargeData.userID, (error, result) ->
# 								if result
# 									chargeData.source = result.id
# 									Meteor.call 'STRIPE_single_charge', chargeData, (error, result) ->
# 										`var result`
# 										if result.error
# 											# $('#giveError').html('<p>'+result.error.message+'</p>').fadeIn();
# 											$(event.currentTarget).attr 'disabled', false
# 											FlashMessages.sendError result.error.message
# 											hideLoadingMask()
# 										else
# 											result = result.result
# 											if result.status == 'succeeded'
# 												id = addTithe(result)
# 												if id
# 													hideLoadingMask()
# 													if $('#email').val() or result.userID
# 														Meteor.call 'sendGiveReciept', $('#email').val(), id
# 													Router.go '/thanks/' + id
# 										return
# 								return
# 						else
# 							chargeData.source = response.id
# 							Meteor.call 'STRIPE_single_charge', chargeData, (error, result) ->
# 								`var result`
# 								if result.error
# 									# $('#giveError').html('<p>'+result.error.message+'</p>').fadeIn();
# 									$(event.currentTarget).attr 'disabled', false
# 									FlashMessages.sendError result.error.message
# 									hideLoadingMask()
# 								else
# 									result = result.result
# 									if result.status == 'succeeded'
# 										id = addTithe(result)
# 										if id
# 											hideLoadingMask()
# 											if $('#email').val() or result.userID
# 												Meteor.call 'sendGiveReciept', $('#email').val(), id
# 											Router.go '/thanks/' + id
# 								return
# 					else
# 						# $('#giveError').html(response.error.message).fadeIn();
# 						$(event.currentTarget).attr 'disabled', false
# 						FlashMessages.sendError response.error.message
# 						hideLoadingMask()
# 					return
#
# 				###
# 											 Meteor.call('STRIPE_single_charge',chargeData,function(error,result){
# 												 if(error){
#
# 															 FlashMessages.sendError(error.message);
# 															 hideLoadingMask();
# 													 }
# 												 if(result.error){
# 															 FlashMessages.sendError(result.error.message);
# 															 hideLoadingMask();
# 													 }else{
# 															 var result = result.result;
# 															 if(result.status == 'succeeded'){
# 																	 var id = addTithe(result)
#
# 																	 if(id){
# 																			 hideLoadingMask();
# 																			 Router.go('/thanks/'+id)
# 																	 }
# 															 }
# 													 }
# 											 });
# 				###
#
# 		else
# 			$(event.currentTarget).attr 'disabled', false
# 		return
# 	'click .btnBlockAmount': (e, t) ->
# 		amount = $(e.currentTarget).attr('data-value')
# 		$('.btnBlockAmount').removeClass 'blue'
# 		$(e.currentTarget).removeClass 'basic'
# 		$(e.currentTarget).addClass 'blue'
# 		if amount == 'other'
# 			$('.inputAmount').show()
# 			$('.btnBlockAmount').hide()
# 			Session.set 'giveAmount', ''
# 			$('.total').empty()
# 		else
# 			Session.set 'giveAmount', amount
# 			$('.total').empty().html ' $' + amount
# 		return
# 	'click .editable-clear-x': (e, t) ->
# 		$('.inputAmount').hide()
# 		Session.set 'giveAmount', ''
# 		$('.total').empty()
# 		$('.btnBlockAmount').show()
# 		return
#
# Template.give.rendered = (event, template) ->
# 	if @data.cardCount > 0
# 		$('.card_data').hide()
# 		$('#card_select').show()
# 	else
# 		$('.card_data').show()
# 		$('#card_select').hide()
# 	$('#giveForm').bootstrapValidator
# 		message: 'This value is not valid'
# 		feedbackIcons:
# 			valid: 'glyphicon glyphicon-ok'
# 			invalid: 'glyphicon glyphicon-remove'
# 			validating: 'glyphicon glyphicon-refresh'
# 		fields:
# 			card:
# 				message: 'You must provide a credit card number.'
# 				validators:
# 					notEmpty: message: 'The credit card number is required'
# 					creditCard: message: 'The credit card number is not valid'
# 			exp:
# 				message: 'You must provide a valid expiration date MM/YY.'
# 				validators:
# 					callback:
# 						message: 'You must provide a valid expiration date MM/YY'
# 						callback: (value, validator) ->
# 							m = new moment(value, 'MM/YY', true)
# 							if !m.isValid()
# 								return false
# 							true
# 					notEmpty: message: 'Expiration date is required MM/YY'
# 			cvc: validators:
# 				cvv:
# 					creditCardField: 'card'
# 					message: 'The CVC / security number is not valid'
# 				notEmpty: message: 'The CVC / security number is required'
# 			email: validators: emailAddress: message: 'The value is not a valid email address'
# 	$('.giveFormNoCC').bootstrapValidator
# 		message: 'This value is not valid'
# 		feedbackIcons:
# 			valid: 'glyphicon glyphicon-ok'
# 			invalid: 'glyphicon glyphicon-remove'
# 			validating: 'glyphicon glyphicon-refresh'
# 		fields:
# 			amount:
# 				message: 'You must provide a gift amount.'
# 				validators:
# 					greaterThan:
# 						inclusive: true
# 						value: 3
# 						message: 'Your tithe must be at least $3.'
# 					notEmpty: message: 'You must select a donation amount.'
# 			card_select:
# 				message: 'You must select a credit card.'
# 				validators: notEmpty: message: 'The credit card number is required'
# 	$('.inputAmount').hide()
# 	if @data.code and @data.code.Goal_Donation
# 		start = 0
# 		goal = @data.code.Goal_Donation
# 		current = @data.titheTotalGive
# 		percent = Math.round(100 * (current - start) / (goal - start))
# 		if percent == 100 and current != goal
# 			percent = 99
# 		if percent > 100
# 			percent = 100
# 		if percent < 0
# 			percent = 0
# 		if percent >= 100
# 			tooltip = '$' + current + ' - goal achieved!'
# 		else
# 			tooltip = '$' + current + ' / ' + percent + '% towards goal'
# 		html = '<div class="dollartimes-pb" style="font-family: arial; width: 300px; box-sizing: border-box; clear:both;">' + '<div class="dollartimes-pb-title" style="font-size:16px; overflow: hidden;">Total Donations to campaign</div>' + '<div class="dollartimes-pb-title" style="font-size:12px; overflow: hidden;">' + tooltip + '</div>' + '<div><div class="dollartimes-pb-frame" title="' + tooltip + '" style="border-radius: 5px; background-color: #ffffff;padding: 0px;border: 1px solid #000; height: 30px; margin: 2px 0 1px;">' + '<div class="dollartimes-pb-fill" style="width:' + percent + '%; height: 100%; margin-top: 0px; background: repeating-linear-gradient(-45deg, rgba(156,28,90,1), rgba(156,28,90,1) 8px, rgba(156,28,90,0.8) 8px, rgba(156,28,90,0.8) 16px);">&nbsp;</div></div>' + '<span class="dollartimes-pb-caption" style="float: left; font-size: 12px;">$' + start + '</span>' + '<span class="dollartimes-pb-caption" style="float: right; font-size: 12px;">$' + goal + '</span></div>' + '<div style="clear: both;"></div><div style="margin: 2px 0 0 0; text-align: right;">' + '<a href="http://www.dollartimes.com/on-your-site/progress-bar.htm?name=My%20Savings&start=0&goal=' + goal + '&current=' + current + '&color=9c1c5a&unit=%24&unitposition=left&size=300" style="font-size: 10px;text-decoration:none;color:#bbb"></a></div></div>'
# 		$('.donationTracker').html html
# 	return
