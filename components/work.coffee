# Router.route '/work', -> @render 'work'
Router.route '/work/', -> @render 'work'
Router.route '/work/:doc_id/view', -> @render 'work_view'
Router.route '/work/:doc_id/edit', -> @render 'work_edit'


if Meteor.isClient
    Template.work.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'work'
        @autorun -> Meteor.subscribe 'model_docs', 'work'
        @autorun => Meteor.subscribe 'model_docs', 'work_stats'


    Template.work.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000




    Template.work_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work.helpers
        work: ->
            Docs.find
                model:'work'
        work_stats_doc: ->
            Docs.findOne
                model:'work_stats'

    Template.work.events
        'click .add_work': ->
            new_id = Docs.insert
                model:'work'
            Router.go "/work/#{new_id}/edit"

        'click .recalc_work': ->
            Meteor.call 'recalc_work', ->



    Template.my_unit_work.helpers
        my_unit_work: ->
            Docs.find {model:'work'},
                sort: _timestamp: -1
                limit:10

    Template.all_work.helpers
        all_work: ->
            Docs.find {model:'work'},
                sort: _timestamp: -1
                limit:10

    Template.my_building_work.helpers
        my_building_work: ->
            Docs.find {model:'work'},
                sort: _timestamp: -1
                limit:10


    Template.my_assignments.onCreated ->
        @autorun => Meteor.subscribe 'my_assignments'
    Template.my_assignments.helpers
        my_assigments: ->
            Docs.find {
                model:'work'
                assigned_to_username: Meteor.user().username
                },
                sort: _timestamp: -1
                limit:10

    Template.latest_work.onCreated ->
        @autorun => Meteor.subscribe 'latest_work'
    Template.latest_work.helpers
        latest_work: ->
            Docs.find {
                model:'work'
            },
                sort: _timestamp: -1
                limit:10



if Meteor.isServer
    Meteor.publish 'my_assignments', ->
        Docs.find {
            model:'work'
            assigned_to_username: Meteor.user().username
        }

    Meteor.methods
        recalc_work: ->
            work_stat_doc = Docs.findOne(model:'work_stats')
            unless work_stat_doc
                new_id = Docs.insert
                    model:'work_stats'
                work_stat_doc = Docs.findOne(model:'work_stats')
            console.log work_stat_doc
            total_count = Docs.find(model:'work').count()
            complete_count = Docs.find(model:'work', complete:true).count()
            incomplete_count = Docs.find(model:'work', complete:$ne:true).count()
            total_updates_count = Docs.find(model:'work_update').count()
            Docs.update work_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
                    total_updates_count:total_updates_count
