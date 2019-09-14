if Meteor.isClient
    Template.footer.events
        'click .shortcut_modal': ->
            $('.ui.shortcut.modal').modal('show')

    Template.nav.events
        # 'mouseenter .item': (e,t)->
        #     $(e.currentTarget).closest('.item').transition('pulse')


        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'

        'click .set_models': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'model', ->
                Session.set 'loading', false

        # 'click .set_work_order': ->
        #     Session.set 'loading', true
        #     Meteor.call 'set_facets', 'work_order', ->
        #         Session.set 'loading', false
        #
        # 'click .set_units': ->
        #     Session.set 'loading', true
        #     Meteor.call 'set_facets', 'unit', ->
        #         Session.set 'loading', false
        #
        'click .set_offer': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'offer', ->
                Session.set 'loading', false
        'click .set_service': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'service', ->
                Session.set 'loading', false
        'click .set_product': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'product', ->
                Session.set 'loading', false
        'click .set_rental': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'rental', ->
                Session.set 'loading', false
        'click .set_request': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'request', ->
                Session.set 'loading', false
        'click .set_shop': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'shop', ->
                Session.set 'loading', false
        'click .set_food': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'food', ->
                Session.set 'loading', false
        #
        # 'click .set_library': ->
        #     Session.set 'loading', true
        #     Meteor.call 'set_facets', 'library', ->
        #         Session.set 'loading', false
        #
        # 'click .set_event': ->
        #     Session.set 'loading', true
        #     Meteor.call 'set_facets', 'event', ->
        #         Session.set 'loading', false
        #
        # 'click .set_task': ->
        #     Session.set 'loading', true
        #     Meteor.call 'set_facets', 'task', ->
        #         Session.set 'loading', false
        'click .set_model': ->
            Session.set 'loading', true
            Docs.update @_id,
                $inc:views:1
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false
        'click .spinning': ->
            Session.set 'loading', false

    Template.footer_chat.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'footer_chat'
    Template.footer_chat.helpers
        chat_messages: ->
            Docs.find
                model:'footer_chat'
    Template.footer_chat.events
        'keyup .new_footer_chat_message': (e,t)->
            if e.which is 13
                new_message = $('.new_footer_chat_message').val()
                Docs.insert
                    model:'footer_chat'
                    text:new_message
                $('.new_footer_chat_message').val('')

        'click .remove_message': (e,t)->
            # if confirm 'remove message?'
            $(e.currentTarget).closest('.item').transition('fade right')
            Meteor.setTimeout =>
                Docs.remove @_id
            , 750

    Template.nav.onRendered ->
        # @autorun =>
        #     if @subscriptionsReady()
        #         Meteor.setTimeout ->
        #             $('.dropdown').dropdown()
        #         , 3000

        Meteor.setTimeout ->
            $('.item').popup(
                preserve:true;
                hoverable:true;
            )
        , 3000

    Template.mlayout.onCreated ->
        @autorun -> Meteor.subscribe 'me'
    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'role_models'
        @autorun -> Meteor.subscribe 'users_by_role','staff'

        # @autorun -> Meteor.subscribe 'current_session'
        # @autorun -> Meteor.subscribe 'unread_messages'

    Template.nav.helpers
        notifications: ->
            Docs.find
                model:'notification'
        role_models: ->
            if Meteor.user() and Meteor.user().roles
                if 'dev' in Meteor.user().roles
                    Docs.find {
                        model:'model'
                    }, sort:title:1
                else
                    Docs.find {
                        model:'model'
                        view_roles:$in:Meteor.user().roles
                    }, sort:title:1

        models: ->
            Docs.find
                model:'model'

        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()

        cart_amount: ->
            cart_amount = Docs.find({
                model:'cart_item'
                _author_id:Meteor.userId()
            }).count()

        mail_icon_class: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()
            if unread_count then 'red' else ''


        bookmarked_models: ->
            if Meteor.userId()
                Docs.find
                    model:'model'
                    bookmark_ids:$in:[Meteor.userId()]


    Template.my_latest_activity.onCreated ->
        @autorun -> Meteor.subscribe 'my_latest_activity'
    Template.my_latest_activity.helpers
        my_latest_activity: ->
            Docs.find {
                model:'log_event'
                _author_id:Meteor.userId()
            },
                sort:_timestamp:-1
                limit:5


    Template.latest_activity.onCreated ->
        @autorun -> Meteor.subscribe 'latest_activity'
    Template.latest_activity.helpers
        latest_activity: ->
            Docs.find {
                model:'log_event'
            },
                sort:_timestamp:-1
                limit:5

if Meteor.isServer
    Meteor.publish 'my_notifications', ->
        Docs.find
            model:'notification'
            user_id: Meteor.userId()

    Meteor.publish 'my_latest_activity', ->
        Docs.find {
            model:'log_event'
            _author_id: Meteor.userId()
        },
            limit:5
            sort:_timestamp:-1

    Meteor.publish 'latest_activity', ->
        Docs.find {
            model:'log_event'
        },
            limit:5
            sort:_timestamp:-1

    Meteor.publish 'bookmarked_models', ->
        if Meteor.userId()
            Docs.find
                model:'model'
                bookmark_ids:$in:[Meteor.userId()]


    Meteor.publish 'my_cart', ->
        if Meteor.userId()
            Docs.find
                model:'cart_item'
                _author_id:Meteor.userId()

    Meteor.publish 'unread_messages', (username)->
        if Meteor.userId()
            Docs.find {
                model:'message'
                to_username:username
                read_ids:$nin:[Meteor.userId()]
            }, sort:_timestamp:-1


    Meteor.publish 'me', ->
        Meteor.users.find @userId
