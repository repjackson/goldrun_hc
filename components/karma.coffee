if Meteor.isClient
    Template.karma_transaction.onCreated ->
        console.log @
        @autorun => Meteor.subscribe 'offers', @data._id

    Template.karma_transaction.helpers
        requests: ->
            Docs.find {model:'shift_change_request'},
                sort: date: -1


    Template.karma_transaction.events
        'click .offer_karma': (e,t)->
            val = parseInt t.$('.offer_karma_amount').val()        
            Docs.insert
                model:'offer'

    Template.request_row.events
        'click .declare_unavailable': (e,t)->
            Docs.update @_id,
                $addToSet:unavailable:Meteor.user().username

        'click .take_shift': (e,t)->
            Docs.update @_id,
                $set:assigned_staff:Meteor.user().username




if Meteor.isServer
    Meteor.publish 'offers', (marketplace_id)->
        Docs.find
            parent_id:marketplace_id
            model: 'offer'
