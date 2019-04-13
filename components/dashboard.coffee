if Meteor.isClient
    Template.dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'model'

    Template.dashboard.helpers
        models: -> Docs.find type: 'model'


    Template.home.events
        'click #add_model': ->
            id = Docs.insert
                type: 'model'
            Router.go "/edit/#{id}"


    Template.edit_lf_item.helpers
        doc: ->
            doc_id = Router.getParam 'doc_id'
            Docs.findOne  doc_id


    Template.task_card.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'task'
    Template.task_card.helpers
        tasks: -> Docs.find type:'task'

    Template.healthclub_card.onCreated ->
        @autorun -> Meteor.subscribe 'checkedin_members'
    Template.healthclub_card.helpers
        checked_in_count: -> Meteor.users.find(healthclub_checkedin:true).count()


    Template.service_card.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'service'
    Template.service_card.helpers
        services: -> Docs.find type:'service'




    Template.buildings_card.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'building'
    Template.buildings_card.helpers
        buildings: -> Docs.find {type:'building'}, sort:building_code:1


    Template.post_card.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'post'
    Template.post_card.helpers
        posts: -> Docs.find type:'post'

    Template.post_card.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'post'
    Template.post_card.helpers
        posts: -> Docs.find type:'post'


if Meteor.isServer
    Meteor.publish 'checkedin_members', ->
        Meteor.users.find
            healthclub_checkedin:true
