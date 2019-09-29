if Meteor.isClient
    Template.member_tasks.onCreated ->
        @autorun => Meteor.subscribe 'assigned_tasks',
            Router.current().params.username
            Session.get 'view_complete'

        @autorun => Meteor.subscribe 'referenced_in_tasks',
            Router.current().params.username
            Session.get 'view_complete'

    Template.member_tasks.helpers
        view_complete_class: ->
            if Session.equals('view_complete',true) then 'grey' else ''

        assigned_tasks: ->
            Docs.find
                model:'task'
                assigned_to_multiple:Router.current().params.username
        referenced_in_tasks: ->
            Docs.find
                model:'task'
                related_people:Router.current().params.username

    Template.member_tasks.events
        'click .view_complete': ->
            Session.set 'view_complete', !Session.get('view_complete')

        'keyup .assign_task': (e,t)->
            if e.which is 13
                post = t.$('.assign_task').val().trim()
                console.log post
                current_user = Meteor.users.findOne username:Router.current().params.username
                Docs.insert
                    body:post
                    model:'task'
                    assigned_user_id:current_user._id
                    assigned_username:current_user.username

                t.$('.assign_task').val('')


    Template.member_wall.events
        'click .remove_comment': ->
            if confirm 'Remove Comment?'
                Docs.remove @_id

        'click .vote_up_comment': ->
            if @upvoters and Meteor.userId() in @upvoters
                Docs.update @_id,
                    $inc:points:1
                    $addToSet:upvoters:Meteor.userId()
                Meteor.users.update @_author_id,
                    $inc:points:-1
            else
                Meteor.users.update @_author_id,
                    $pull:upvoters:Meteor.userId()
                    $inc:points:1
                Meteor.users.update @_author_id,
                    $inc:points:1

        'click .mark_comment_read': ->
            Docs.update @_id,
                $addToSet:readers:Meteor.userId()



    Template.member_messages.onCreated ->
        @autorun => Meteor.subscribe 'user_messages',Router.current().params.username
        @autorun => Meteor.subscribe 'users'



    Template.member_messages.helpers
        user_messages: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'message'
                to_username:current_user.username
            }, sort:_timestamp:-1

    Template.member_messages.events
        'keyup #new_message': (e,t)->
            if e.which is 13
                body = t.$('#new_message').val().trim()
                console.log body
                current_user = Meteor.users.findOne username:Router.current().params.username
                Docs.insert
                    body:body
                    model:'message'
                    to_user_id:current_user._id
                    to_username:current_user.username

                t.$('#new_message').val('')


    Template.notify_message.events
        'click .notify': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.insert
                model:'log_event'
                body:"#{current_user.username} was notified about message: #{@body} by #{Meteor.user().username}."
                user_ids:[current_user._id,Meteor.userId()]
                to_user_id:current_user._id
                to_username:current_user.username
            Meteor.call 'notify_message', @_id


if Meteor.isServer
    Meteor.publish 'user_messages', (username)->
        match = {}
        match.model = 'message'
        match.to_username = username
        Docs.find match


    Meteor.publish 'assigned_tasks', (username)->
        Docs.find
            model:'task'
            assigned_to_multiple: $in: [username]


    Meteor.publish 'referenced_in_tasks', (username)->
        Docs.find
            model:'task'
            related_people: $in: [username]
