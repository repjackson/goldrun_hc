Router.route '/blog', -> @render 'blog'
Router.route '/post/:doc_id/view', -> @render 'post_view'
Router.route '/post/:doc_id/edit', -> @render 'post_edit'



if Meteor.isClient
    Template.blog.onCreated ->
        @autorun => Meteor.subscribe 'blog'
    Template.blog.onRendered ->
    Template.blog.helpers
        posts: ->
            Docs.find
                model:'post'
    Template.blog.events
        'click .add_blog_item': ->
            new_id = Docs.insert
                model:'post'
            Router.go "/post/#{new_id}/edit"



    Template.post_card.events
        'click .view_post': ->
            Docs.update @_id,
                $inc:views:1
            Router.go "/post/#{_id}/view"


    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current.params().doc_id
    Template.post_view.onRendered ->
    Template.post_view.helpers
    Template.blog.events
        'click .buy_now': ->
            Docs.insert
                model:'transaction'
                post_id: Router.current.params().doc_id
                started:true
                completed:false
            Router.go "/transaction/#{_id}/view"




    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current.params().doc_id
    Template.post_edit.onRendered ->
    Template.post_edit.helpers
        posts: ->
            Docs.find
                model:'blog'
    Template.blog.events
        'click .view_post': ->
            Docs.update @_id,
                $inc:views:1
            Router.go "/post/#{_id}/view"


if Meteor.isServer
    Meteor.publish 'blog', ->
        Docs.find
            model:$in:['post','service','rental','food']
