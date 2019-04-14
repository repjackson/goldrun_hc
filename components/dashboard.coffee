if Meteor.isClient
    Template.dashboard.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'model')

    Template.dashboard.helpers
        models: -> Docs.find type: 'model'

    Template.home.events
        'click #add_model': ->
            id = Docs.insert
                type: 'model'
            Router.go "/edit/#{id}"



if Meteor.isServer
    Meteor.publish 'checkedin_members', ->
        Meteor.users.find
            healthclub_checkedin:true
