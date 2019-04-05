if Meteor.isClient
    Template.nav.events
        'click #logout': ->
            Meteor.logout()


    Template.nav.onCreated ->
        @autorun ->
            Meteor.subscribe 'me'
            Meteor.subscribe 'my_notifications'

    Template.nav.helpers
        notifications: ->
            Docs.find
                type:'notification'



if Meteor.isServer
    Meteor.publish 'my_notifications', ->
        Docs.find
            type:'notification'
            user_id: Meteor.userId()


    Meteor.publish 'me', ->
        Meteor.users.find @userId
