# Router.route '/tasks', -> @render 'tasks'
Router.route '/blog', -> @render 'blog'
Router.route '/post/:doc_id/view', -> @render 'post_view'
Router.route '/post/:doc_id/edit', -> @render 'post_edit'


if Meteor.isClient
    Template.blog.onCreated ->
        # @autorun => Meteor.subscribe 'tribe_docs', 'post'
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'post'

    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.blog.helpers
        posts: ->
            Docs.find
                model:'post'
    Template.blog.events
        'click .add_post': ->
            new_id = Docs.insert
                model:'post'
            Router.go "/post/#{new_id}/edit"
