Template.edit_post.onCreated ->
    @autorun -> Meteor.subscribe 'post', FlowRouter.getParam('post_id')

Template.edit_post.helpers
    post: ->
        Posts.findOne FlowRouter.getParam('post_id')
    
        
Template.edit_post.events
    'click #save_post': ->
        title = $('#title').val()
        publish_date = $('#publish_date').val()
        body = $('#body').val()
        Posts.update FlowRouter.getParam('post_id'),
            $set:
                title: title
                publish_date: publish_date
                body: body
        FlowRouter.go "/post/view/#{@_id}"
        
    'blur #title': ->
        title = $('#title').val()
        Posts.update FlowRouter.getParam('post_id'),
            $set: title: title
    
    
    'keydown #add_tag': (e,t)->
        if e.which is 13
            post_id = FlowRouter.getParam('post_id')
            tag = $('#add_tag').val().toLowerCase().trim()
            if tag.length > 0
                Posts.update post_id,
                    $addToSet: tags: tag
                $('#add_tag').val('')

    'click .doc_tag': (e,t)->
        tag = @valueOf()
        Posts.update FlowRouter.getParam('post_id'),
            $pull: tags: tag
        $('#add_tag').val(tag)
        
        
    'click #publish': ->
        Posts.update FlowRouter.getParam('post_id'),
            $set: published: true

    'click #unpublish': ->
        Posts.update FlowRouter.getParam('post_id'),
            $set: published: false

    'click #make_featured': ->
        Posts.update FlowRouter.getParam('post_id'),
            $set: featured: true

    'click #make_unfeatured': ->
        Posts.update FlowRouter.getParam('post_id'),
            $set: featured: false

    'click #delete': ->
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
            post = Posts.findOne FlowRouter.getParam('posts_id')
            Posts.remove post._id, ->
                FlowRouter.go "/posts"
