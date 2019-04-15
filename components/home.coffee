if Meteor.isClient
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'model')

    Template.home.helpers
        models: -> Docs.find model: 'model'

    Template.home.events
        'click #add_model': ->
            id = Docs.insert
                model: 'model'
            Router.go "/edit/#{id}"



if Meteor.isServer
    Meteor.publish 'checkedin_members', ->
        Meteor.users.find
            healthclub_checkedin:true
