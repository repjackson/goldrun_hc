Template.post_view.onCreated ->
    @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_view.helpers
    post: -> Docs.findOne Router.current().params.doc_id


if Meteor.isClient
    Template.my_posts.onCreated ->
        @autorun -> Meteor.subscribe('my_posts')


    Template.my_posts.helpers
        my_posts: ->
            Docs.find {},
                sort:
                    publish_date: -1


if Meteor.isServer
    Meteor.publish 'my_posts', ->
        Docs.find
            author_id: @userId


Template.post_edit.onCreated ->
    @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_edit.helpers
    post: -> Docs.findOne Router.current().params.doc_id


Template.post_edit.events
    'click #delete_post': ->
        swal {
            title: 'Delete?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, ->
            Docs.remove Router.current().params.doc_id, ->
                Router.go "/posts"
