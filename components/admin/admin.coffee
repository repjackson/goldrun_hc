if Meteor.isClient
    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'global_settings'

    Template.member_table.onCreated ->
        @autorun ->  Meteor.subscribe 'users_by_role', 'member'
    Template.member_table.helpers
        members: -> Meteor.users.find {
            roles:$in:['member']
        }
    Template.member_table.events
        'click #add_user': ->

    Template.admin_chat.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'admin_chat'
    Template.admin_chat.helpers
        chat_messages: ->
            Docs.find
                model:'admin_chat'
    Template.admin_chat.events
        'keyup .new_admin_chat_message': (e,t)->
            if e.which is 13
                new_message = $('.new_admin_chat_message').val()
                Docs.insert
                    model:'admin_chat'
                    text:new_message
                $('.new_admin_chat_message').val('')

        'click .remove_message': (e,t)->
            # if confirm 'remove message?'
            $(e.currentTarget).closest('.item').transition('fade right')
            Meteor.setTimeout =>
                Docs.remove @_id
            , 750


    Template.transactions_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'transaction'
    Template.transactions_small.helpers
        transactions: ->
            Docs.find {
                model:'transaction'
            }, sort:_timestamp:-1



    Template.reservations_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'reservation'
        @autorun -> Meteor.subscribe 'model_docs', 'rental'
        @autorun -> Meteor.subscribe 'model_docs', 'reservation_stats'
    Template.reservations_small.helpers
        reservations: ->
            Docs.find {
                model:'reservation'
            }, sort:_timestamp:-1
        res_stat: ->
            Docs.findOne
                model:'reservation_stats'
    Template.reservations_small.events
        'click .refresh_res_stats': ->
            Meteor.call 'calc_reservation_stats',(err,res)->




    Template.admin_wiki.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'wiki'
    Template.admin_wiki.helpers
        wiki: ->
            Docs.find {
                model:'wiki'
            }, sort:_timestamp:-1



    Template.online_users.onCreated ->
        @autorun -> Meteor.subscribe 'online_users'
    Template.online_users.events
        'click .sign_out': ->
            console.log @services
            Meteor.users.update @_id,
                $set: "services.resume.loginTokens":[]
    Template.online_users.helpers
        online_users: ->
            Meteor.users.find {
                "profile.online":true
            }




    Template.user_role_toggle.helpers
        is_in_role: ->
            Template.parentData().roles and @role in Template.parentData().roles
    Template.user_role_toggle.events
        'click .add_role': ->
            parent_user = Template.parentData()
            Meteor.users.update parent_user._id,
                $addToSet:roles:@role
        'click .remove_role': ->
            parent_user = Template.parentData()
            Meteor.users.update parent_user._id,
                $pull:roles:@role



if Meteor.isServer
    Meteor.publish 'online_users', ->
        Meteor.users.find {
            "profile.online":true
        }
