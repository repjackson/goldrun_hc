# Router.route '/tasks', -> @render 'tasks'
Router.route '/tasks/', -> @render 'tasks'
Router.route '/task/:doc_id/view', -> @render 'task_view'
Router.route '/task/:doc_id/edit', -> @render 'task_edit'


if Meteor.isClient
    Template.tasks.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'task'
        @autorun -> Meteor.subscribe 'model_docs', 'task'
        @autorun => Meteor.subscribe 'model_docs', 'task_stats'


    Template.tasks.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000




    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.tasks.helpers
        tasks: ->
            Docs.find
                model:'task'
        task_stats_doc: ->
            Docs.findOne
                model:'task_stats'

    Template.tasks.events
        'click .add_task': ->
            new_id = Docs.insert
                model:'task'
            Router.go "/task/#{new_id}/edit"

        'click .recalc_tasks': ->
            Meteor.call 'recalc_tasks', ->



    Template.my_unit_tasks.helpers
        my_unit_tasks: ->
            Docs.find {model:'task'},
                sort: _timestamp: -1
                limit:10
    Template.all_tasks.helpers
        all_tasks: ->
            Docs.find {model:'task'},
                sort: _timestamp: -1
                limit:10
    Template.my_building_tasks.helpers
        my_building_tasks: ->
            Docs.find {model:'task'},
                sort: _timestamp: -1
                limit:10
    Template.owner_portal.events
        'click .add_task': (e,t)->
            new_id = Docs.insert
                model:'task'
            Router.go "/task/#{new_id}/edit"



if Meteor.isServer
    Meteor.methods
        recalc_tasks: ->
            task_stat_doc = Docs.findOne(model:'task_stats')
            unless task_stat_doc
                new_id = Docs.insert
                    model:'task_stats'
                task_stat_doc = Docs.findOne(model:'task_stats')
            console.log task_stat_doc
            total_count = Docs.find(model:'task').count()
            complete_count = Docs.find(model:'task', complete:true).count()
            incomplete_count = Docs.find(model:'task', complete:$ne:true).count()
            total_updates_count = Docs.find(model:'task_update').count()
            Docs.update task_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
                    total_updates_count:total_updates_count
