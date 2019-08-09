Router.route '/market', -> @render 'market'
Router.route '/product/:doc_id/view', -> @render 'product_view'
Router.route '/product/:doc_id/edit', -> @render 'product_edit'

Router.route '/add_market_item', -> @render 'add_market_item'



if Meteor.isClient
    Template.market.onCreated ->
        @autorun => Meteor.subscribe 'market'
    Template.market.onRendered ->
    Template.market.helpers
        products: ->
            Docs.find
                model:'product'

    Template.market.events
        'click .add_market_item': ->
            #
            # new_id = Docs.insert
            #     model:'product'
            Router.go "/add_market_item"



    Template.add_market_item.events
        'click .add_product': ->
            new_id = Docs.insert
                model:'product'
            Router.go "/product/#{new_id}/edit"

        'click .add_service': ->
            new_id = Docs.insert
                model:'service'
            Router.go "/service/#{new_id}/edit"

        'click .add_food': ->
            new_id = Docs.insert
                model:'food'
            Router.go "/food/#{new_id}/edit"

        'click .add_rental': ->
            new_id = Docs.insert
                model:'rental'
            Router.go "/rental/#{new_id}/edit"




    Template.product_card.events
        'click .view_product': ->
            Docs.update @_id,
                $inc:views:1
            Router.go "/product/#{_id}/view"


    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.product_view.onRendered ->
    Template.product_view.helpers
    Template.market.events
        'click .buy_now': ->
            Docs.insert
                model:'transaction'
                product_id: Router.current().params.doc_id
                started:true
                completed:false
            Router.go "/transaction/#{_id}/view"




    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.product_edit.onRendered ->
    Template.product_edit.helpers
        products: ->
            Docs.find
                model:'market'
    Template.market.events
        'click .view_product': ->
            Docs.update @_id,
                $inc:views:1
            Router.go "/product/#{_id}/view"






if Meteor.isServer
    Meteor.publish 'market', ->
        Docs.find
            model:$in:['product','service','rental','food']
            # active:true
