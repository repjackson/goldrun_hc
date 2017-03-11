Template.post_page.onCreated ->
    @autorun -> Meteor.subscribe 'post', FlowRouter.getParam('post_id')



Template.post_page.helpers
    post: ->
        Posts.findOne FlowRouter.getParam('post_id')


Template.post_page.events
    'click .edit_post': ->
        FlowRouter.go "/post/edit/#{@_id}"
