if Meteor.isClient
    Template.tab.onCreated ->
        @autorun -> Meteor.subscribe 'undelivered_transactions'
        @autorun -> Meteor.subscribe 'shop'

    Template.tab.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000

    Template.tab.events
        'click .checkout_cart': ->
            if confirm 'complete checkout?'
                cart_items = Docs.find(model:'cart_item').fetch()
                for cart_item in cart_items
                    referenced_product =
                        Docs.findOne
                            _id:cart_item.product_id
                    Meteor.users.update Meteor.userId(),
                        $inc:karma:-referenced_product.karma_price
                    # total_cart_cost += referenced_product.karma_price
                    Docs.insert
                        model:'transaction'
                        product_id:referenced_product._id
                        purchase_price:referenced_product.karma_price
                        user_karma_before:Meteor.user().karma
                        user_karma_after:Meteor.user().karma-referenced_product.karma_price
                $('.cart_item').transition(
                    animation: 'fly right'
                    duration: 1000
                    interval: 200
                    onComplete: ()=>
                        for cart_item in cart_items
                            Docs.remove cart_item._id
                        Router.go '/transactions'
                )

    Template.tab.helpers
        transactions: ->
            Docs.find
                model:'transaction'

        total_tab_cost: ->
            total_tab_cost = 0
            tab_items = Docs.find(model:'transaction').fetch()
            for tab_item in tab_items
                referenced_product =
                    Docs.findOne
                        _id:tab_item.product_id
                total_tab_cost += referenced_product.dollar_price
            total_tab_cost

        can_buy: ->
            total_cart_cost = 0
            cart_items = Docs.find(model:'cart_item').fetch()
            for cart_item in cart_items
                referenced_product =
                    Docs.findOne
                        _id:cart_item.product_id
                total_cart_cost += referenced_product.karma_price
            total_cart_cost < Meteor.user().karma






    Template.transactions.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'transaction'
        @autorun -> Meteor.subscribe 'model_docs', 'shop'
        # @autorun -> Meteor.subscribe 'shop'
    Template.transactions.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000
    Template.transactions.events
    Template.transactions.helpers
        transactions: ->
            Docs.find
                model:'transaction'


    Template.my_transactions.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'transaction'
        @autorun -> Meteor.subscribe 'model_docs', 'shop'
        # @autorun -> Meteor.subscribe 'shop'
    Template.my_transactions.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.my_transactions.events
    Template.my_transactions.helpers
        transactions: ->
            Docs.find
                model:'transaction'
                _author_id:Meteor.userId()


if Meteor.isServer
    Meteor.publish 'undelivered_transactions', ->
        Docs.find
            model:'transaction'
            delivered:false
            _author_id: Meteor.userId()
