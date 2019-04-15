if Meteor.isClient
    Template.nav.events
        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'


    Template.sidebar.events
        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'


    Template.nav.onCreated ->
        @autorun ->
            Meteor.subscribe 'me'
            Meteor.subscribe 'my_notifications'
            # Meteor.subscribe 'type', 'model'

    Template.nav.helpers
        notifications: ->
            Docs.find
                type:'notification'

        models: ->
            Docs.find
                type:'model'

    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.context .ui.sidebar')
                .sidebar({
                    context: $('.context .segment')
                    dimPage: false
                    transition:  'push'
                })
                .sidebar('attach events', '.context .menu .toggle_sidebar.item')
        , 1000

    Template.nav.events
        'click .sidebar_on': ->
            $('.context .ui.sidebar')
                .sidebar({
                    context: $('.context .segment')
                    dimPage: false
                    transition:  'push'
                })
                .sidebar('attach events', '.context .menu .toggle_sidebar.item')


if Meteor.isServer
    Meteor.publish 'my_notifications', ->
        Docs.find
            type:'notification'
            user_id: Meteor.userId()


    Meteor.publish 'me', ->
        Meteor.users.find @userId
