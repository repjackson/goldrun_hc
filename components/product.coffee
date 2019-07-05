if Meteor.isClient
    Template.shop_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shop_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shop_view_layout.events
        'click .add_to_cart': ->
            console.log @
            Docs.insert
                model:'cart_item'
                product_id:@_id
            $('body').toast({
                title: "#{@title} added to cart."
                # message: 'Please see desk staff for key.'
                class : 'green'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })



    Template.product_transactions.onRendered ->
        Template.children_view.onRendered ->
            Meteor.setTimeout ->
                $('.accordion').accordion()
            , 1000

    Template.product_transactions.onCreated ->
        @autorun => Meteor.subscribe 'product_transactions', Router.current().params.doc_id
    Template.product_transactions.events
        'click .add_transaction': ->
            console.log @
            Docs.insert
                model:'transaction'
                product_id: @_id
                transaction_type:'purchase'
            Meteor.call 'calculate_product_inventory_amount', @_id
    Template.product_transactions.helpers
        product_transactions: ->
            Docs.find
                model:'transaction'
                product_id: Router.current().params.doc_id


    Template.shop_stats.onCreated ->
        @autorun => Meteor.subscribe 'shop_stats', Router.current().params.doc_id
    Template.shop_stats.events
        'click .advise_price': ->
            Meteor.call 'advise_price', @_id
        'click .calculate_transaction_count': ->
            # console.log @
            Meteor.call 'calculate_product_inventory_amount', @_id
    Template.shop_stats.helpers
        product_transactions: ->
            Docs.find
                model:'transaction'
                product_id: Router.current().params.doc_id



    Template.product_ads.onCreated ->
        @autorun => Meteor.subscribe 'product_ads', Router.current().params.doc_id
    Template.product_ads.events
        'click .create_product_ad': ->
            Docs.insert
                model:'product_ad'
                product_id:Router.current().params.doc_id
            Meteor.call 'advise_price', @_id
        'click .calculate_transaction_count': ->
            # console.log @
            Meteor.call 'calculate_product_inventory_amount', @_id
    Template.product_ads.helpers
        product_transactions: ->
            Docs.find
                model:'transaction'
                product_id: Router.current().params.doc_id
