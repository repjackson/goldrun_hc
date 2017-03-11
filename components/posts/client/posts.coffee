Template.posts.onCreated ->
    @autorun -> Meteor.subscribe('selected_posts', selected_post_tags.array())

Template.posts.onRendered ->
    $('#blog_slider').layerSlider
        autoStart: true


Template.posts.helpers
    posts: -> 
        Posts.find {},
            sort:
                publish_date: -1
            limit: 10
            
Template.posts.events
    'click #add_post': ->
        id = Posts.insert {}
        FlowRouter.go "/post/edit/#{id}"




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
        FlowRouter.go "/post/edit/#{@_id}"
