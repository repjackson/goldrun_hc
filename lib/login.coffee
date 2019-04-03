if Meteor.isClient
    Template.login.onCreated ->
        Session.set 'username', null

    Template.login.events
        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'


        'click .enter': (e,t)->
            username = $('.username').val()
            password = $('.password').val()
            # if Session.equals 'enter_mode', 'register'
            # if confirm "register #{username}?"
            options = {
                username:username
                password:password
                }
            console.log options
            Meteor.loginWithPassword username, password, (err,res)=>
                if err
                    console.log err
                    alert err.reason
                    # if err.error is 403
                    #     Session.set 'message', "#{username} not found"
                    #     Session.set 'enter_mode', 'register'
                    #     Session.set 'username', "#{username}"
                else
                    console.log res

                    Router.go "/dashboard"
            # else
            #     Meteor.loginWithPassword username, password, (err,res)=>
            #         if err
            #             if err.error is 403
            #                 Session.set 'message', "#{username} not found"
            #                 Session.set 'enter_mode', 'register'
            #                 Session.set 'username', "#{username}"
            #         else
            #             Router.go '/'


    Template.login.helpers
        username: -> Session.get 'username'

        logging_in: -> Session.equals 'enter_mode', 'login'

        enter_class: ->
            if Meteor.loggingIn() then 'loading disabled' else ''


# if Meteor.isServer
    # Meteor.methods
    #     create_user: (options)->
    #         Accounts.createUser options
    #
    #
    #
    #     find_username: (username)->
    #         res = Accounts.findUserByUsername(username)
    #         return res
    #
    #     new_demo_user: ->
    #         current_user_count = Meteor.users.find().count()
    #         console.log 'current_user_count', current_user_count
    #
    #         options = {
    #             username:"user#{current_user_count}"
    #             password:"user#{current_user_count}"
    #             }
    #
    #         create = Accounts.createUser options
    #         console.log 'create', create
    #         new_user = Meteor.users.findOne create
    #         return new_user
