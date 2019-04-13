if Meteor.isClient
    Router.route '/tasks', -> @render 'tasks'
    Router.route '/task/:doc_id/edit', -> @render 'task_edit'
    Router.route '/task/:doc_id/view', -> @render 'task_view'


    # Template.task.onRendered ->
    #     Meteor.setTimeout (->
    #         $('.shape').shape()
    #     ), 500


    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'task'

    Template.tasks.onRendered ->
        # Meteor.setTimeout (->
        #     $('table').tablesort()
        #     # $('select.dropdown').dropdown()
        # ), 500



    Template.task_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'docs', [], 'building'


    Template.tasks.helpers
        tasks: -> Docs.find { type: 'task' }

    Template.task_edit.helpers


    Template.tasks.events
        'click #add_task': ->
            id = Docs.insert type:'task'
            Router.go "/task/#{id}/edit"
