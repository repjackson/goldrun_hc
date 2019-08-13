if Meteor.isClient
    Template.tasks.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'task'
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.tasks.helpers
        my_tasks: ->
            Docs.find
                model:'task'

    Template.tasks.events
        'click .add_task': ->
            new_id = Docs.insert
                model:'task'
            Router.go "/task/#{new_id}/edit"
