# Router.route '/tasks', -> @render 'tasks'
Router.route '/projects/', -> @render 'projects'
Router.route '/project/:doc_id/view', -> @render 'project_view'
Router.route '/project/:doc_id/edit', -> @render 'project_edit'


if Meteor.isClient
    Template.projects.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'project'

    Template.project_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.project_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'users_by_role', 'board_member'

    Template.project_card.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.project_card.onCreated ->
        @autorun => Meteor.subscribe 'children', 'project_update', @data._id
    Template.project_card.helpers
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



    Template.project_edit.helpers
        board_members: ->
            Meteor.users.find
                roles:$in:['board_member']
    Template.projects.helpers
        projects: ->
            Docs.find
                model:'project'
    Template.projects.events
        'click .add_project': ->
            new_id = Docs.insert
                model:'project'
            Router.go "/project/#{new_id}/edit"
