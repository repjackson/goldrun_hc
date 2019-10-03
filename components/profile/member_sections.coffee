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



    Template.member_reservations.onCreated ->
        @autorun => Meteor.subscribe 'member_reservations', Router.current().params.username
    Template.member_reservations.helpers
        reservations: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'reservation'
            }, sort:_timestamp:-1






    Template.member_finance.onCreated ->
        @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'payment'
        @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'withdrawel'
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
                user = Meteor.users.findOne username:Router.current().params.username
                deposit_amount = parseInt $('.deposit_amount').val()*100
                stripe_charge = deposit_amount*100*1.02+20
                # calculated_amount = deposit_amount*100
                # console.log calculated_amount
                charge =
                    amount: deposit_amount
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
                    if error then alert error.reason, 'danger'
                    else
                        alert 'payment received', 'success'
                        Docs.insert
                            model:'payment'
                            deposit_amount:deposit_amount/100
                            stripe_charge:stripe_charge
                            amount_with_bonus:deposit_amount*1.05/100
                            bonus:deposit_amount*.05/100
                        Meteor.users.update user._id,
                            $inc: credit: deposit_amount*1.05/100

    	)


    Template.member_finance.events
        'click .add_credits': ->
            deposit_amount = parseInt $('.deposit_amount').val()*100
            # calculated_amount = deposit_amount*100*1.02+20
            Template.instance().checkout.open
                name: 'top up'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: deposit_amount

        'click .initial_withdrawel': ->
            withdrawel_amount = parseInt $('.withdrawel_amount').val()
            if confirm "initiate withdrawel for #{withdrawel_amount}?"
                Docs.insert
                    model:'withdrawel'
                    amount: withdrawel_amount
                    status: 'started'
                    complete: false
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -withdrawel_amount

        'click .cancel_withdrawel': ->
            if confirm "cancel withdrawel for #{@amount}?"
                Docs.remove @_id
                Meteor.users.update Meteor.userId(),
                    $inc: credit: @amount

    Template.member_finance.helpers
        joint_transactions: ->
            Docs.find
                model:'reservation'
                recipient:Router.current().params.username
                # confirmed:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1

        withdrawels: ->
            Docs.find {
                model:'withdrawel'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1

        received_reservations: ->
            Docs.find {
                model:'reservation'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1

        purchased_reservations: ->
            Docs.find {
                model:'reservation'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1




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



    Template.member_rentals.onCreated ->
        @autorun => Meteor.subscribe 'member_rentals', Router.current().params.username
    Template.member_rentals.helpers
        rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'rental'
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

    Meteor.publish 'member_rentals', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'rental'
            _author_username:username
            # _author_id: current_user._id

    Meteor.publish 'member_reservations', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'reservation'
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
