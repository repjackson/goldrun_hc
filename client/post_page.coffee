Template.post_page.onCreated ->
    @autorun -> Meteor.subscribe 'doc', Router.current().param.doc_id



Template.post_page.helpers
    post: -> Docs.findOne Router.current().param.doc_id


Template.post_page.events
    'click .edit_post': ->
        Router.go "/post/edit/#{@_id}"




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




Template.edit_post.onCreated ->
    @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

Template.edit_post.helpers
    post: -> Docs.findOne Router.current().params.doc_id


Template.edit_post.events
    'click #save_post': ->
        title = $('#title').val()
        publish_date = $('#publish_date').val()
        body = $('#body').val()
        Docs.update Router.current().params.doc_id,
            $set:
                title: title
                publish_date: publish_date
                body: body
        Router.go "/post/view/#{@_id}"

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
