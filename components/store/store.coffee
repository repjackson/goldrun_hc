FlowRouter.route '/store', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'store'






if Meteor.isClient
    Template.store.onCreated -> 
        @autorun -> Meteor.subscribe('store')

    
    
    Template.store.helpers
        store_items: ->
            Docs.find
                type: 'product'

        
        price_total: ->
            total = 0
            me = Meteor.users.findOne Meteor.userId()
            if me
                for item in Docs.find( _id: $in: [me.profile.store] ).fetch()
                    total = total + item.point_price
                total


    Template.store.events
        'click #add_product': ->
            new_id = Docs.insert 
                type: 'product'
            FlowRouter.go "/edit_product/#{new_id}"    
    
    
        'click .remove_item': ->
            Meteor.users.update Meteor.userId(),
                $pull: 'profile.store': @_id
        
        
        
if Meteor.isServer
    Meteor.publish 'store', ->
        Docs.find 
            type: 'product'
    
    
    Meteor.methods
        add_to_store: (doc_id)->
            Meteor.users.update Meteor.userId(),
                $addToSet: "profile.store": doc_id