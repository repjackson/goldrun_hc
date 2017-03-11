if Meteor.isClient
    Template.comments.onCreated ->
        @autorun => Meteor.subscribe('comments', @data._id )
        
    Template.comments.onRendered ->
        
        
    Template.comments.helpers
        comments: -> 
            Docs.find {
                type: 'comment'
                doc_id: @_id
                }
                
                
    Template.add_comment.events
        'click #add_comment': ->
            text = $('#new_comment_text').val()
            id = Docs.insert
                type: 'comment'
                doc_id: @_id
                body: text


if Meteor.isServer
    Meteor.publish 'comments', (doc_id)->
        Docs.find
            type: 'comment'
            doc_id: doc_id
