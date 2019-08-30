# Router.route '/tasks', -> @render 'tasks'
Router.route '/events/', -> @render 'events'
Router.route '/event/:doc_id/view', -> @render 'event_view'
Router.route '/event/:doc_id/edit', -> @render 'event_edit'


if Meteor.isClient
    Template.events.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'event'

    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.events.helpers
        events: ->
            Docs.find
                model:'event'
    Template.events.events
        'click .add_event': ->
            new_id = Docs.insert
                model:'event'
            Router.go "/event/#{new_id}/edit"
