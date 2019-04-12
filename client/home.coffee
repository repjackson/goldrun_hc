if Meteor.isClient
    Template.dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'model'

    Template.dashboard.helpers
        models: ->
            Docs.find
                type: 'model'


    Template.home.events
        'click #add_model': ->
            id = Docs.insert
                type: 'model'
            Router.go "/edit/#{id}"


    Template.edit_lf_item.helpers
        doc: ->
            doc_id = Router.getParam 'doc_id'
            Docs.findOne  doc_id


    Template.my_tasks.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'task'
    Template.my_tasks.helpers
        tasks: ->
            Docs.find
                type:'task'




    Template.buildings_card.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'building'
    Template.buildings_card.helpers
        buildings: ->
            Docs.find {type:'building'}, sort:building_code:1


    Template.post_card.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'post'
    Template.post_card.helpers
        posts: ->
            Docs.find
                type:'post'

    Template.post_card.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'post'
    Template.post_card.helpers
        posts: ->
            Docs.find
                type:'post'
