Template.profile_layout.onCreated ->
    @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
    @autorun -> Meteor.subscribe 'user_schemas', Router.current().params.username

Template.user_section.helpers
    user_section_template: ->
        "user_#{Router.current().params.group}"

Template.profile_layout.helpers
    user: ->
        Meteor.users.findOne username:Router.current().params.username

    user_schemas: ->
        user = Meteor.users.findOne username:Router.current().params.username
        Docs.find
            type:'schema'
            _id:$in:user.schema_ids



Template.profile_layout.events
    'click .set_delta_schema': ->
        console.log @
        Meteor.call 'set_delta_facets', @slug, null, true

    'click .logout': ->
        Meteor.logout()
        Router.go '/login'


Template.user_array_element_toggle.helpers
    user_array_element_toggle_class: ->
        # user = Meteor.users.findOne Router.current().params.username
        if @user["#{@key}"] and @value in @user["#{@key}"] then 'grey' else ''


Template.user_array_element_toggle.events
    'click .toggle_element': (e,t)->
        # console.log @
        # user = Meteor.users.findOne Router.current().params.username
        if @user["#{@key}"]
            if @value in @user["#{@key}"]
                Meteor.users.update @user._id,
                    $pull: "#{@key}":@value
            else
                Meteor.users.update @user._id,
                    $addToSet: "#{@key}":@value
        else
            Meteor.users.update @user._id,
                $addToSet: "#{@key}":@value


Template.user_array_list.helpers
    users: ->
        users = []
        if @user["#{@array}"]
            for user_id in @user["#{@array}"]
                user = Meteor.users.findOne user_id
                users.push user
            users



Template.user_array_list.onCreated ->
    @autorun => Meteor.subscribe 'user_array_list', @data.user, @data.array

Template.user_array_list.helpers
    users: ->
        users = []
        if @user["#{@array}"]
            for user_id in @user["#{@array}"]
                user = Meteor.users.findOne user_id
                users.push user
            users
