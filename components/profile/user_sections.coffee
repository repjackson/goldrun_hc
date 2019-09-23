if Meteor.isClient
    Template.user_wall.onCreated ->
        @autorun => Meteor.subscribe 'wall_posts', Router.current().params.username
    Template.user_wall.helpers
        wall_posts: ->
            Docs.find
                model:'wall_post'
    Template.user_wall.events
        'keyup .new_post': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if e.which is 13
                post = t.$('.new_post').val().trim()
                Docs.insert
                    body:post
                    model:'wall_post'
                    user_id:current_user._id
                t.$('.new_post').val('')
        'click .remove_comment': ->
            if confirm 'remove comment?'
                Docs.remove @_id
        'click .vote_up_comment': ->
            if @upvoters and Meteor.userId() in @upvoters
                Docs.update @_id,
                    $inc:points:1
                    $addToSet:upvoters:Meteor.userId()
                Meteor.users.update @author_id,
                    $inc:points:-1
            else
                Meteor.users.update @author_id,
                    $pull:upvoters:Meteor.userId()
                    $inc:points:1
                Meteor.users.update @author_id,
                    $inc:points:1

        'click .mark_comment_read': ->
            Docs.update @_id,
                $addToSet:readers:Meteor.userId()


    Template.user_bookmarks.onCreated ->
        @autorun => Meteor.subscribe 'user_bookmarks', Router.current().params.username
    Template.user_bookmarks.helpers
        bookmarks: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                bookmark_ids:$in:[current_user._id]
            }, sort:_timestamp:-1






    Template.user_transactions.onCreated ->
        @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.user_transactions.helpers
        user_transactions: ->
            Docs.find
                model:'karma_transaction'
                recipient:Router.current().params.username
                # confirmed:true





    Template.user_connect_button.onCreated ->
        # @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.user_connect_button.helpers
        connected: ->
            Meteor.user().connected_ids and @_id in Meteor.user().connected_ids
    Template.user_connect_button.events
        'click .toggle_connection': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse', 200)

            if Meteor.user().connected_ids and @_id in Meteor.user().connected_ids
                Meteor.users.update Meteor.userId(),
                    $pull: connected_ids: @_id
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet: connected_ids: @_id



    Template.user_tags.onCreated ->
        @autorun => Meteor.subscribe 'user_tag_reviews', Router.current().params.username
    Template.user_tags.helpers
        user_tag_reviews: ->
            Docs.find
                model:'user_tag_review'
        my_tag_review: ->
            Docs.findOne
                model:'user_tag_review'
                _author_id: Meteor.userId()





    Template.user_tags.events
        'click .new_tag_review': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.insert
                model:'user_tag_review'
                user_id:current_user._id





if Meteor.isServer
    Meteor.publish 'wall_posts', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'wall_post'
            user_id: current_user._id

    Meteor.publish 'user_tag_reviews', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'user_tag_review'
            user_id: current_user._id
