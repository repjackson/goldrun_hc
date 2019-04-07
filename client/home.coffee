if Meteor.isClient
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'model'

    Template.home.helpers
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
