if Meteor.isClient
    Template.member_wall.onCreated ->
        @autorun => Meteor.subscribe 'wall_posts', Router.current().params.username
    Template.member_wall.helpers
        wall_posts: ->
            Docs.find
                model:'wall_post'
    Template.member_wall.events
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


    Template.member_bookmarks.onCreated ->
        @autorun => Meteor.subscribe 'user_bookmarks', Router.current().params.username
    Template.member_bookmarks.helpers
        bookmarks: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                bookmark_ids:$in:[current_user._id]
            }, sort:_timestamp:-1






    Template.member_finance.onCreated ->
        @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # product = Docs.findOne Router.current().params.doc_id
                username = Router.current().params.username
                charge =
                    amount: 1040
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, username, (error, response) =>
                    if error then alert error.reason, 'danger'
                    else
                        alert 'Payment received.', 'success'
                        # Docs.insert
                        #     model:'transaction'
                        #     product_id:product._id
    	)


    Template.member_finance.events
        'click .add_credits': ->
            Template.instance().checkout.open
                name: 'top up'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: 1040

    Template.member_finance.helpers
        joint_transactions: ->
            Docs.find
                model:'reservation'
                recipient:Router.current().params.username
                # confirmed:true




    Template.member_services.onCreated ->
        @autorun => Meteor.subscribe 'member_services', Router.current().params.username
    Template.member_services.helpers
        services: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'service'
                _author_username:current_user.username
                # _author_id:current_user._id
                # confirmed:true





    Template.member_connect_button.onCreated ->
        # @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.member_connect_button.helpers
        connected: ->
            Meteor.user().connected_ids and @_id in Meteor.user().connected_ids
    Template.member_connect_button.events
        'click .toggle_connection': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse', 200)

            if Meteor.user().connected_ids and @_id in Meteor.user().connected_ids
                Meteor.users.update Meteor.userId(),
                    $pull: connected_ids: @_id
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet: connected_ids: @_id






    Template.member_info.onCreated ->
        # @autorun => Meteor.subscribe 'user_confirmed_transactions', Router.current().params.username
    Template.member_info.helpers
        connected: ->
            Meteor.user().connected_ids and @_id in Meteor.user().connected_ids
    Template.member_info.events
        'click .refresh_member_stats': (e,t)->
            Meteor.call 'refresh_member_stats', Router.current().params.username



    Template.member_tags.onCreated ->
        @autorun => Meteor.subscribe 'user_tag_reviews', Router.current().params.username
    Template.member_tags.helpers
        user_tag_reviews: ->
            Docs.find
                model:'user_tag_review'
        my_tag_review: ->
            Docs.findOne
                model:'user_tag_review'
                _author_id: Meteor.userId()





    Template.member_tags.events
        'click .new_tag_review': (e,t)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.insert
                model:'user_tag_review'
                user_id:current_user._id


    Template.member_connections.onCreated ->
        @autorun => Meteor.subscribe 'user_connected_to', Router.current().params.username
        @autorun => Meteor.subscribe 'user_connected_by', Router.current().params.username
    Template.member_connections.helpers
        connected_to: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user.connected_ids
                Meteor.users.find
                    _id:$in:current_user.connected_ids
        connected_by: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                connected_ids:$in:[current_user._id]



if Meteor.isServer
    Meteor.publish 'joint_transactions', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'reservation'
            user_id: current_user._id

    Meteor.publish 'member_services', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'service'
            _author_username:username
            # _author_id: current_user._id

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

    Meteor.methods
        refresh_member_stats: (username)->
            member = Meteor.users.findOne username:username
            service_count = Docs.find(model:'service', _author_username:username).count()
            rental_count = Docs.find(model:'rental', _author_username:username).count()
            product_count = Docs.find(model:'product', _author_username:username).count()
            reservation_count = Docs.find(model:'reservation', _author_username:username).count()
            comment_count = Docs.find(model:'comment', _author_username:username).count()
            Meteor.users.update member._id,
                $set:
                    service_count: service_count
                    rental_count: rental_count
                    product_count: product_count
                    reservation_count: reservation_count
                    comment_count: comment_count
