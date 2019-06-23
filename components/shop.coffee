if Meteor.isClient
    Template.shop_card.onCreated ->

    Template.shop.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.shop.onCreated ->
        @autorun -> Meteor.subscribe 'shop'
    Template.shop.helpers
        products: ->
            Docs.find
                model:'shop'


    Template.add_to_tab.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'transaction'
    Template.add_to_tab.events
        'click .add_to_tab': ->
            Meteor.call 'create_transaction', @

        'click .remove_tab_item': ->
            Docs.remove @_id

    Template.add_to_tab.helpers
        current_tab_additions: ->
            console.log @
            Docs.find
                model:'transaction'
                product_id:@_id







    Template.shop_card.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000

    Template.shop_card.events
        'click .add_to_cart': ->
            if Meteor.user()
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
            else
                Router.go '/login'



    Template.shop_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shop_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.product_transactions.onCreated ->
        @autorun => Meteor.subscribe 'product_transactions', Router.current().params.doc_id

    Template.product_transactions.helpers
        product_transactions: ->
            Docs.find
                model:'transaction'
                product_id: Router.current().params.doc_id



if Meteor.isServer
    Meteor.methods
        create_transaction: (product)->
            console.log product
            Docs.insert
                model:'transaction'
                product_id:product._id
                delivered:false




    Meteor.publish 'product_transactions', (product_id)->
        Docs.find
            model:'transaction'
            product_id:product_id


    Meteor.publish 'shop', ->
        Docs.find
            model:'shop'
            active:true
