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


    Template.shop_card.helpers
        current_ad: ->
            Docs.findOne
                model:'ad'


# if Meteor.isServer
    # Meteor.publish 'shop', ->
    #     Docs.find
    #         model:'ad'
