if Meteor.isClient
    Template.cart.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'shop'
        # @autorun -> Meteor.subscribe 'shop'

    Template.cart.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000

    Template.cart.events
        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'cart_item'
        #         product_id:@_id


    Template.cart.helpers
        cart_items: ->
            Docs.find
                model:'cart_item'
        referenced_product: ->
            Docs.findOne
                _id:@product_id

        total_cart_cost: ->
            total_cart_cost = 0
            cart_items = Docs.find(model:'cart_item').fetch()
            for cart_item in cart_items
                referenced_product =
                    Docs.findOne
                        _id:cart_item.product_id
                total_cart_cost += referenced_product.karma_price
            total_cart_cost



# if Meteor.isServer
    # Meteor.publish 'shop', ->
    #     Docs.find
    #         model:'ad'
