FlowRouter.route '/item/view/:item_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'view_item'


if Meteor.isClient
    Template.view_item.onCreated ->
        @autorun -> Meteor.subscribe 'item', FlowRouter.getParam('item_id')
    
        Template.instance().checkout = StripeCheckout.configure(
            key: Meteor.settings.public.stripe.testPublishableKey
            # image: 'https://tmc-post-content.s3.amazonaws.com/ghostbusters-logo.png'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # console.log token
                product = Items.findOne FlowRouter.getParam('item_id')
                # console.log product
                charge = 
                    amount: product.price*100
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    receipt_email: token.email
                Meteor.call 'processPayment', charge, (error, response) ->
                    if error then Bert.alert error.reason, 'danger'
                    else Bert.alert 'Thanks for your payment.', 'success'
            # closed: ->
            #     alert 'closed'

              # We'll pass our token and purchase info to the server here.
        )


    
    Template.view_item.helpers
        item: ->
            Items.findOne FlowRouter.getParam('item_id')
    
    
    
    Template.view_item.events
        'click .edit': ->
            item_id = FlowRouter.getParam('item_id')
            FlowRouter.go "/item/edit/#{item_id}"

        'click #buy': ->
            Template.instance().checkout.open
                name: @title
                # description: @description
                amount: @price*100
                bitcoin: true


if Meteor.isServer
    Meteor.publish 'item', (item_id) ->
        Items.find item_id
    
    
    Stripe = StripeAPI(Meteor.settings.private.stripe.testSecretKey)
    # console.log Meteor.settings.private.stripe.testSecretKey
    Meteor.methods
        processPayment: (charge) ->
            handleCharge = Meteor.wrapAsync(Stripe.charges.create, Stripe.charges)
            payment = handleCharge(charge)
            console.log payment
            payment
