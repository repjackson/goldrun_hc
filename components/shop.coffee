if Meteor.isClient
    Template.shop_card.onCreated ->
        # @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'shop'

    Template.shop_card.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000

    Template.shop_card.events
        'click .add_to_cart': ->
            console.log @
            Docs.insert
                model:'cart_item'
                product_id:@_id


    Template.shop_card.helpers
        current_ad: ->
            Docs.findOne
                model:'ad'


# if Meteor.isServer
    # Meteor.publish 'shop', ->
    #     Docs.find
    #         model:'ad'
