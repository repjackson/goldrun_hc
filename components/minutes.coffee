# Router.route '/tasks', -> @render 'tasks'
Router.route '/minutes/', -> @render 'minutes'
Router.route '/minute/:doc_id/view', -> @render 'minute_view'
Router.route '/minute/:doc_id/edit', -> @render 'minute_edit'


if Meteor.isClient
    Template.minutes.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'minute'

    Template.minute_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.minute_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'users_by_role', 'board_member'

    Template.minute_edit.helpers
        board_members: ->
            Meteor.users.find
                roles:$in:['board_member']
    Template.minutes.helpers
        minutes: ->
            Docs.find
                model:'minute'
    Template.minutes.events
        'click .add_minute': ->
            new_id = Docs.insert
                model:'minute'
            Router.go "/minute/#{new_id}/edit"
