if Meteor.isClient
    Template.comments.onCreated ->
        @autorun => Meteor.subscribe('comments', @data._id )
        
    Template.comments.onRendered ->
        
        
    Template.comments.helpers
        comments: -> 
            Comments.find {
                type: 'comment'
                doc_id: @_id
                }
                
                
    Template.add_comment.events
        'click #add_comment': ->
            text = $('#new_comment_text').val()
            id = Comments.insert
                doc_id: @_id
                body: text


if Meteor.isServer
    Meteor.publish 'comments', (doc_id)->
        Comments.find
            doc_id: doc_id
