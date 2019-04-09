if Meteor.isClient
    Router.route '/posts', -> @render 'posts'
    Router.route '/post/:doc_id/edit', -> @render 'post_edit'
    Router.route '/post/:doc_id/view', -> @render 'post_view'

    @selected_post_tags = new ReactiveArray []

    Template.posts.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_post_tags.array(), 'post')

    Template.posts.helpers
        posts: ->
            Docs.find {},
                sort:
                    publish_date: -1
                limit: 10

    Template.posts.events
        'click #add_post': ->
            id = Docs.insert type: 'post'
            Router.go "/post/#{id}/edit"


    Template.post.helpers
        tag_class: -> if @valueOf() in selected_post_tags.array() then 'primary' else 'basic'
        can_edit: -> @author_id is Meteor.userId()


    Template.post_item.helpers
        tag_class: -> if @valueOf() in selected_post_tags.array() then 'primary' else 'basic'
        can_edit: -> @author_id is Meteor.userId()



    Template.post.events
        'click .post_tag': ->
            if @valueOf() in selected_post_tags.array() then selected_post_tags.remove @valueOf() else selected_post_tags.push @valueOf()

        'click .edit_post': ->
            Router.go "/post/#{@_id}/edit"
