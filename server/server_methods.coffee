Meteor.methods
    add_resident: (first_name,last_name,username)->
        profile = {}
        profile.first_name = first_name
        profile.last_name = last_name
        options = {}
        options.username = username
        options.profile = profile

        res= Accounts.createUser options
        if res
            return res
        else
            Throw.new Meteor.Error 'err creating user'
        # console.log 'created user', res
