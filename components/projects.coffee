# Router.route '/tasks', -> @render 'tasks'
Router.route '/projects/', -> @render 'projects'
Router.route '/project/:doc_id/view', -> @render 'project_view'
Router.route '/project/:doc_id/edit', -> @render 'project_edit'


if Meteor.isClient
    Template.projects.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'project_stats'
        @autorun => Meteor.subscribe 'model_docs', 'project_update'
        @autorun => Meteor.subscribe 'model_comments', 'project'
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'project'

    Template.project_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.project_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'users_by_role', 'board_member'

    Template.project_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.project_card_template.onCreated ->
        @autorun => Meteor.subscribe 'children', 'project_update', @data._id
    Template.project_card_template.helpers
        updates: ->
            Docs.find
                model:'project_update'
                parent_id: @_id


    Template.project_view.onCreated ->
        @autorun => Meteor.subscribe 'children', 'project_update', Router.current().params.doc_id
    Template.project_view.helpers
        updates: ->
            Docs.find
                model:'project_update'
                parent_id: Router.current().params.doc_id


    Template.activity.onCreated ->
        @autorun => Meteor.subscribe 'children', 'project_update', Template.currentData()._id
        # @autorun => Meteor.subscribe 'model_docs', 'project_update'
    Template.activity.helpers
        updates: ->
            Docs.find
                model:'project_update'
                parent_id: Template.currentData()._id
    Template.activity.events
        'click .add_update': ->
            new_update_id = Docs.insert
                model:'project_update'
                parent_id: @_id
            Router.go "/m/project_update/#{new_update_id}/edit"


    Template.project_edit.helpers
        board_members: ->
            Meteor.users.find
                roles:$in:['board_member']




    Template.projects.helpers
        projects: ->
            Docs.find
                model:'project'
        latest_comments: ->
            Docs.find {
                model:'comment'
                parent_model:'project'
            },
                limit:5
                sort:_timestamp:-1
        project_stats_doc: ->
            Docs.findOne
                model:'project_stats'

    Template.projects.events
        'click .add_project': ->
            new_id = Docs.insert
                model:'project'
            Router.go "/project/#{new_id}/edit"

        'click .recalc_projects': ->
            Meteor.call 'recalc_projects', ->

    Template.latest_project_updates.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'project_update'
    Template.latest_project_updates.helpers
        latest_updates: ->
            Docs.find {
                model:'project_update'
            },
                limit:5
                sort:_timestamp:-1



    Template.project_finance.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'project_payment'
    Template.project_finance.events
        'click .add_payment': ->
            Docs.insert
                model:'project_payment'
                project_id: Router.current().params.doc_id
        'click .refresh': ->
            Meteor.call 'calculate_project_payment_totals', Router.current().params.doc_id
    Template.project_finance.helpers
        payments: ->
            Docs.find {
                model:'project_payment'
            },
                limit:10
                sort:payment_date:-1




    Template.project_files_small.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'file'
    Template.project_files_small.events
        'click .add_file': ->
            Docs.insert
                model:'file'
                project_id: Router.current().params.doc_id
    Template.project_files_small.helpers
        files: ->
            Docs.find {
                model:'file'
            },
                limit:10
                sort:file_date:-1



    Template.project_files.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'file'
    Template.project_files.events
        'click .add_file': ->
            Docs.insert
                model:'file'
                project_id: Router.current().params.doc_id
    Template.project_files.helpers
        files: ->
            Docs.find {
                model:'file'
            },
                limit:10
                sort:file_date:-1






if Meteor.isServer
    Meteor.publish 'model_comments', (parent_model)->
        Docs.find
            model:'comment'
            parent_model:parent_model
    Meteor.methods
        calculate_project_payment_totals: (project_id)->
            project = Docs.findOne project_id
            payments = Docs.find(
                model:'project_payment'
                project_id:project_id
            ).fetch()
            payment_total = 0
            for payment in payments
                payment_total+=payment.amount
            console.log 'payment total', payment_total
            Docs.update project_id,
                $set:payment_total:payment_total

        recalc_projects: ->
            project_stat_doc = Docs.findOne(model:'project_stats')
            unless project_stat_doc
                new_id = Docs.insert
                    model:'project_stats'
                project_stat_doc = Docs.findOne(model:'project_stats')
            console.log project_stat_doc
            total_count = Docs.find(model:'project').count()
            complete_count = Docs.find(model:'project', complete:true).count()
            incomplete_count = Docs.find(model:'project', complete:$ne:true).count()
            total_updates_count = Docs.find(model:'project_update').count()
            Docs.update project_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
                    total_updates_count:total_updates_count
