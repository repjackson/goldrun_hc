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

    checkout_members: ()->
        now = Date.now()
        checkedin_members = Meteor.users.find(healthclub_checkedin:true).fetch()
        console.log 'previous checked in members', checkedin_members
        for member in checkedin_members
            console.log member
        Meteor.users.update({healthclub_checkedin:true},{$set:healthclub_checkedin:false},{multi:true})
        checkedin_members = Meteor.users.find(healthclub_checkedin:true).fetch()
        console.log 'now checked in members', checkedin_members


    lookup_user: (username_query, role_filter)->
        # console.log role_filter
        Meteor.users.find({
            username: {$regex:"#{username_query}", $options: 'i'}
            roles:$in:[role_filter]
            }).fetch()

    lookup_user_by_code: (healthclub_code)->
        # console.log healthclub_code
        Meteor.users.find({
            healthclub_code:healthclub_code
            }).fetch()

    lookup_doc: (first_name, model_filter)->
        # console.log first_name
        # console.log model_filter
        Docs.find({
            model:model_filter
            first_name: {$regex:"#{first_name}", $options: 'i'}
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



    keys: (specific_key)->
        start = Date.now()

        if specific_key
            console.log 're-keying docs with', specific_key
            cursor = Docs.find({
                "#{specific_key}":$exists:true
                _keys:$exists:false
                }, { fields:{_id:1} })
        else
            cursor = Docs.find({
                _keys:$exists:false
            }, { fields:{_id:1} })

        found = cursor.count()
        console.log 'found', found, 'docs with', specific_key

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

        stop = Date.now()

        diff = stop - start
        # console.log diff
        console.log 'duration', moment(diff).format("HH:mm:ss:SS")

    key: (doc_id)->
        doc = Docs.findOne doc_id
        keys = _.keys doc
        # console.log doc

        light_fields = _.reject( keys, (key)-> key.startsWith '_' )
        # console.log light_fields

        Docs.update doc._id,
            $set:_keys:light_fields

        console.log "keyed #{doc._id}"

    global_remove: (keyname)->
        console.log 'removing', keyname, 'globally'
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})
        console.log result
        console.log 'removed', keyname, 'globally'


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()
        console.log 'key count', count




    slugify: (title)->
        slug = title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        console.log 'title', title
        console.log 'slug', slug
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        console.log 'start renaming', old, 'to', newk

        old_count = Docs.find({"#{old}":$exists:true}).count()
        console.log 'found',old_count,'of',old

        new_count = Docs.find({"#{newk}":$exists:true}).count()
        console.log 'found',new_count,'of',newk


        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})

        console.log 'mongo update call finished:',result

        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

        console.log 'done renaming', old, 'to', newk

        console.log 'result1', result
        console.log 'result2', result2





    detect_fields: (doc_id)->
        doc = Docs.findOne doc_id
        keys = _.keys doc
        light_fields = _.reject( keys, (key)-> key.startsWith '_' )
        console.log light_fields

        Docs.update doc._id,
            $set:_keys:light_fields

        for key in light_fields
            value = doc["#{key}"]

            meta = {}

            js_type = typeof value

            console.log 'key type', key, js_type

            if js_type is 'object'
                meta.object = true
                if Array.isArray value
                    meta.array = true
                    meta.length = value.length
                    meta.array_element_type = typeof value[0]
                    meta.field = 'array'
                else
                    if key is 'watson'
                        meta.field = 'object'
                        # meta.field = 'watson'
                    else
                        meta.field = 'object'

            else if js_type is 'boolean'
                meta.boolean = true
                meta.field = 'boolean'

            else if js_type is 'number'
                meta.number = true
                d = Date.parse(value)
                # nan = isNaN d
                # !nan
                if value < 0
                    meta.negative = true
                else if value > 0
                    meta.positive = false

                integer = Number.isInteger(value)
                if integer
                    meta.integer = true
                meta.field = 'number'


            else if js_type is 'string'
                meta.string = true
                meta.length = value.length

                html_check = /<[a-z][\s\S]*>/i
                html_result = html_check.test value

                url_check = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
                url_result = url_check.test value

                youtube_check = /((\w|-){11})(?:\S+)?$/
                youtube_result = youtube_check.test value
                console.log youtube_result

                if key is 'html'
                    meta.html = true
                    meta.field = 'html'
                if key is 'youtube_id'
                    meta.youtube = true
                    meta.field = 'youtube'
                else if html_result
                    meta.html = true
                    meta.field = 'html'
                else if url_result
                    meta.url = true
                    image_check = (/\.(gif|jpg|jpeg|tiff|png)$/i).test value
                    if image_check
                        meta.image = true
                        meta.field = 'image'
                    else
                        meta.field = 'url'
                # else if youtube_result
                #     meta.youtube = true
                #     meta.field = 'youtube'
                else if Meteor.users.findOne value
                    meta.user_id = true
                    meta.field = 'user_ref'
                else if Docs.findOne value
                    meta.doc_id = true
                    meta.field = 'doc_ref'
                else if meta.length is 20
                    meta.field = 'image'
                else if meta.length > 20
                    meta.field = 'textarea'
                else
                    meta.field = 'text'

            Docs.update doc_id,
                $set: "_#{key}": meta

        # Docs.update doc_id,
        #     $set:_detected:1
        # console.log 'detected fields', doc_id

        return doc_id
