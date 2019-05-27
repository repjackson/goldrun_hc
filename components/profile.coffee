if Meteor.isClient
    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_models', Router.current().params.username


    Template.user_section.helpers
        user_section_template: ->
            "user_#{Router.current().params.group}"

    Template.user_layout.helpers
        user: ->
            Meteor.users.findOne username:Router.current().params.username

        user_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids

        banner_style: ->
            console.log @
            # {
            #     background: url(/image/signup-bg.png) center no-repeat;
            #     /*height: 100%;*/
            #     width: 100%;
            #     height: 100vh;
            #     background-repeat: no-repeat;
            #     background-position: center center;
            #     background-size: cover;
            #     background-attachment: fixed;
            #     position: relative;
            # }




    Template.user_layout.events
        'click .set_delta_model': ->
            console.log @
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Meteor.logout()
            Router.go '/login'

    Template.user_healthclub.events
        'click .generate_barcode': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user.healthclub_code
                JsBarcode("#barcode", current_user.healthclub_code);
            else
                alert 'No healthclub code'



    Template.user_array_element_toggle.helpers
        user_array_element_toggle_class: ->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"] and @value in @user["#{@key}"] then 'black' else 'basic'


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




    # Template.user_connections.onCreated ->
    #     @autorun => Meteor.subscribe 'all_users', Router.current().params.username
    #
    # Template.user_connections.helpers
    #     connections: ->
    #         Meteor.users.find {}
    #
    # Template.user_connections.events
    #     'keyup .assign_task': (e,t)->
    #         if e.which is 13
    #             post = t.$('.assign_task').val().trim()
    #             console.log post
    #             current_user = Meteor.users.findOne username:Router.current().params.username
    #             Docs.insert
    #                 body:post
    #                 model:'task'
    #                 assigned_user_id:current_user._id
    #                 assigned_username:current_user.username
    #
    #             t.$('.assign_task').val('')



    Template.user_wall.onCreated ->
        @autorun => Meteor.subscribe 'wall_posts', Router.current().params.username
    Template.user_wall.helpers
        wall_posts: ->
            Docs.find
                model:'wall_post'
    Template.user_wall.events
        'keyup .new_post': (e,t)->
            if e.which is 13
                post = t.$('.new_post').val().trim()
                Docs.insert
                    body:post
                    model:'wall_post'
                t.$('.new_post').val('')
        'click .remove_comment': ->
            if confirm 'Remove Comment?'
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



    Template.violations.onCreated ->
        @autorun => Meteor.subscribe 'violations', Router.current().params.username
    Template.violations.helpers
        violations: ->
            Docs.find
                model:'violation'


    Template.user_transactions.onCreated ->
        @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.user_transactions.helpers
        user_transactions: ->
            Docs.find
                model:'karma_transaction'
                recipient:Router.current().params.username
                # confirmed:true

    Template.received_karma.onCreated ->
        @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.received_karma.helpers
        received_karma: ->
            Docs.find
                model:'karma_transaction'
                recipient:Router.current().params.username
                # confirmed:true





    Template.user_key.onCreated ->
        @autorun => Meteor.subscribe 'user_key', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'unit_key_access'
    Template.user_key.helpers
        key: -> Docs.findOne model:'key'
        viewing_code: -> Session.get 'viewing_code'
        access_log: ->
            Docs.find {
                model:'unit_key_access'
                key_id:Docs.findOne(model:'key')._id
            }, sort:_timestamp:-1
    Template.user_key.events
        'click .view_code': ->
            access = prompt 'admin code'
            if access is '2959'
                Session.set 'viewing_code', true
                # console.log access
                Meteor.setTimeout ->
                    Session.set 'viewing_code', false
                , 5000
                new_id = Docs.insert
                    model:'unit_key_access'
                    key_id:Docs.findOne(model:'key')._id
                    owner_user_id:Meteor.users.findOne username:Router.current().params.username
                    owner_username:Router.current().params.username
                # console.log new_id
            else
                alert 'wrong code'



    Template.user_unit.onCreated ->
        @autorun => Meteor.subscribe 'user_unit', Router.current().params.username
    Template.user_unit.helpers
        unit: ->
            Docs.findOne
                model:'unit'


    Template.user_guests.onCreated ->
        @autorun => Meteor.subscribe 'user_guests', Router.current().params.username
    Template.user_guests.helpers
        guests: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'guest'
                _id:$in:user.guest_ids




    Template.user_checkins.onCreated ->
        @autorun => Meteor.subscribe 'healthclub_checkins', Router.current().params.username
    Template.user_checkins.helpers
        healthclub_checkins: ->
            Docs.find
                model:'healthclub_checkin'
                resident_username:Router.current().params.username




    Template.user_log.onCreated ->
        @autorun => Meteor.subscribe 'user_log', Router.current().params.username
    Template.user_log.helpers
        user_log_events: ->
            Docs.find {
                model:'log_event'
            }, sort:_timestamp:-1


    Template.user_bookmarks.onCreated ->
        @autorun => Meteor.subscribe 'user_bookmarks', Router.current().params.username
    Template.user_bookmarks.helpers
        bookmarks: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            console.log current_user
            Docs.find {
                bookmark_ids:$in:[current_user._id]
            }, sort:_timestamp:-1



    Template.membership_status.events
        'click .email_rules_receipt': ->
            console.log @
            Meteor.call 'send_rules_regs_receipt_email', @_id



if Meteor.isServer
    Meteor.publish 'wall_posts', (username)->
        # console.log username
        Docs.find
            model:'wall_post'
            # parent_username:username

    Meteor.publish 'healthclub_checkins', (username)->
        # console.log username
        Docs.find
            model:'healthclub_checkin'
            resident_username:username

    Meteor.publish 'user_key', (username)->
        # console.log 'violation', username
        user = Meteor.users.findOne username:username
        # console.log user
        Docs.find
            model:'key'
            building_number:user.building_number
            unit_number:user.unit_number



    Meteor.publish 'user_unit', (username)->
        # console.log 'violation', username
        user = Meteor.users.findOne username:username
        # console.log user
        Docs.find
            model:'unit'
            building_code:user.building_code
            unit_number:user.unit_number


    Meteor.publish 'user_bookmarks', (username)->
        # console.log 'violation', username
        user = Meteor.users.findOne username:username
        console.log user
        Docs.find
            bookmark_ids:$in:[user._id]


    Meteor.publish 'violations', (username)->
        # console.log 'violation', username
        Docs.find
            model:'violation'
            parent_username:username

    Meteor.publish 'user_confirmed_transactions', (username)->
        # console.log 'violation', username
        Docs.find
            model:'karma_transaction'
            recipient:username
            # confirmed:true


    Meteor.publish 'user_guests', (username)->
        # console.log 'violation', username
        user = Meteor.users.findOne username:username
        Docs.find
            model:'guest'
            _id:$in:user.guest_ids


    Meteor.publish 'user_log', (username)->
        # console.log 'violation', username
        user = Meteor.users.findOne username:username
        Docs.find
            model:'log_event'
            object_id:user._id
