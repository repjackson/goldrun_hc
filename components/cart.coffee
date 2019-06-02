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


# if Meteor.isServer
    # Meteor.publish 'shop', ->
    #     Docs.find
    #         model:'ad'
