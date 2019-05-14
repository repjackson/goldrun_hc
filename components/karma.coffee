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


    Template.user_karma.onCreated ->
        @autorun => Meteor.subscribe 'doc', Session.get('sending_karma')
    Template.user_karma.events
        'click .send_new': ->
            new_transaction_id =
                Docs.insert
                    model:'karma_transaction'
            Session.set 'sending_karma', new_transaction_id

        'click .cancel_sending': ->
            Docs.remove Session.get('sending_karma')
            Session.set 'sending_karma', null

        'click .complete_sending': ->
            if confirm 'confirm send karma?'
                transaction_doc = Docs.findOne Session.get('sending_karma')
                Docs.update Session.get('sending_karma'),
                    $set:
                        recipient:Router.current().params.username
                        confirmed:true
                amount = transaction_doc.karma_amount
                console.log amount
                Meteor.users.update Meteor.userId(),
                    $inc:karma:-amount
                recipient = Meteor.users.findOne username:Router.current().params.username
                Meteor.users.update recipient._id,
                    $inc:karma:amount
                Session.set 'sending_karma', null

    Template.user_karma.helpers
        sending_karma: -> Session.get 'sending_karma'
        send_karma_transaction: ->
            Docs.findOne(Session.get('sending_karma'))



if Meteor.isServer
    Meteor.publish 'offers', (marketplace_id)->
        Docs.find
            parent_id:marketplace_id
            model: 'offer'
