@Posts = new Meteor.Collection 'posts'

FlowRouter.route '/posts', action: ->
    BlazeLayout.render 'layout', 
        main: 'posts'

FlowRouter.route '/post/edit/:post_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_post'

FlowRouter.route '/post/view/:post_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'post_page'


Posts.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    doc.points = 0
    doc.downvoters = []
    doc.upvoters = []
    return


# Posts.after.insert (userId, doc)->
#     console.log doc.tags
#     return

Posts.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tag_count = doc.tags?.length
    # Meteor.call 'generate_authored_cloud'
), fetchPrevious: true


Posts.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()

