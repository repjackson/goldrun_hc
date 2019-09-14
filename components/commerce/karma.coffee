if Meteor.isClient
    Router.route '/karma', -> @render 'karma'

    Template.karma.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'shop'
        # @autorun -> Meteor.subscribe 'shop'

    Template.karma.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000

    Template.karma.events
        'click .checkout_karma': ->
            if confirm 'complete checkout?'
                karma_items = Docs.find(model:'karma_item').fetch()
                for karma_item in karma_items
                    referenced_product =
                        Docs.findOne
                            _id:karma_item.product_id
                    Meteor.users.update Meteor.userId(),
                        $inc:karma:-referenced_product.karma_price
                    # total_karma_cost += referenced_product.karma_price
                    Docs.insert
                        model:'transaction'
                        product_id:referenced_product._id
                        purchase_price:referenced_product.karma_price
                        user_karma_before:Meteor.user().karma
                        user_karma_after:Meteor.user().karma-referenced_product.karma_price
                $('.karma_item').transition(
                    animation: 'fly right'
                    duration: 1000
                    interval: 200
                    onComplete: ()=>
                        for karma_item in karma_items
                            Docs.remove karma_item._id
                        Router.go '/transactions'
                )



    Template.karma.helpers
        karma_items: ->
            Docs.find
                model:'karma_item'


        total_karma_cost: ->
            total_karma_cost = 0
            karma_items = Docs.find(model:'karma_item').fetch()
            for karma_item in karma_items
                referenced_product =
                    Docs.findOne
                        _id:karma_item.product_id
                total_karma_cost += referenced_product.karma_price
            total_karma_cost


        can_buy: ->
            total_karma_cost = 0
            karma_items = Docs.find(model:'karma_item').fetch()
            for karma_item in karma_items
                referenced_product =
                    Docs.findOne
                        _id:karma_item.product_id
                total_karma_cost += referenced_product.karma_price
            total_karma_cost < Meteor.user().karma
