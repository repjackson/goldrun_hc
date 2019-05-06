Meteor.methods
    add_user: (username)->
        options = {}
        options.username = username

        res= Accounts.createUser options
        if res
            return res
        else
            Throw.new Meteor.Error 'err creating user'
        # console.log 'created user', res

    parse_keys: ->
        cursor = Docs.find
            model:'key'
        for key in cursor.fetch()
            # console.log typeof key.building_number
            # console.log typeof key.building_code
            # console.log typeof key.building_code
            # new_building_number = parseInt key.building_number
            new_unit_number = parseInt key.unit_number
            console.log typeof new_building_code
            console.log typeof new_building_number
            Docs.update key._id,
                $set:
                    unit_number:new_unit_number


    change_username:  (user_id, new_username) ->
        user = Meteor.users.findOne user_id
        Accounts.setUsername(user._id, new_username)
        return "Updated Username to #{new_username}."


    add_email: (user_id, new_email) ->
        Accounts.addEmail(user_id, new_email);
        return "Updated Email to #{new_email}"

    remove_email: (user_id, email)->
        # user = Meteor.users.findOne username:username
        console.log 'removing email', email, 'from', user_id
        Accounts.removeEmail user_id, email


    verify_email: (user_id)-> Accounts.sendVerificationEmail(user_id)

    validateEmail: (email) ->
        re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        re.test String(email).toLowerCase()


    notify_message: (message_id)->
        message = Docs.findOne message_id
        if message
            console.log message
            to_user = Meteor.users.findOne message.to_user_id
            console.log to_user.emails[0].address

            message_link = "https://www.goldrun.online/user/#{to_user.username}/messages"

        	Email.send({
                to:["<#{to_user.emails[0].address}>"]
                from:"relay@goldrun.online"
                subject:"Gold Run Message Notification from #{message._author_username}"
                html: "<h3> #{message._author_username} sent you the message:</h3>"+"<h2> #{message.body}.</h2>"+
                    "<br><h4>View your messages here:<a href=#{message_link}>#{message_link}</a>.</h4>"
            })

    auto_checkout_members: ()->
        now = Date.now()
        checkedin_members = Meteor.users.find(healthclub_checkedin:true).fetch()
        for member in checkedin_members
            console.log member

    lookup_user: (username_query, role_filter)->
        console.log role_filter
        Meteor.users.find({
            username: {$regex:"#{username_query}", $options: 'i'}
            roles:$in:[role_filter]
            }).fetch()

    # lookup_username: (username_query)->
    #     found_users =
    #         Docs.find({
    #             model:'person'
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             }).fetch()
    #     found_users

    # lookup_first_name: (first_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             first_name: {$regex:"#{first_name}", $options: 'i'}
    #             }).fetch()
    #     found_people
    #
    # lookup_last_name: (last_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             last_name: {$regex:"#{last_name}", $options: 'i'}
    #             }).fetch()
    #     found_people


    set_password: (user_id, new_password)->
        Accounts.setPassword(user_id, new_password)
