if Meteor.isClient
    Template.dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'my_products'
        # @autorun -> Meteor.subscribe 'model_docs', 'event'
    Template.dashboard.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.dashboard.helpers
        my_products: ->
            Docs.find
                model:'shop'
                _author_id:Meteor.userId()


    Template.product_viewing.helpers
        readers: ->
            Meteor.users.find
                _id: $in: @reader_ids
        marked_read: ->
            if @read_by_ids
                console.log @reader_ids
            else
                console.log 'no readers'
            if @reader_ids and Meteor.userId() in @reader_ids then true else false

    Template.product_viewing.events
        'click .mark_unread': ->
            Docs.update @_id,
                $pull:reader_ids:Meteor.userId()
                $inc:reader_count:-1
        'click .mark_read': ->
            Docs.update @_id,
                $addToSet:reader_ids:Meteor.userId()
                $inc:reader_count:1





    Template.top_selling_products.onRendered ->
        @autorun -> Meteor.subscribe 'model_docs', 'shop'
    Template.top_selling_products.helpers
        top_products: ->
            Docs.find(
                {
                    model:'shop'
                    _author_id:Meteor.userId()
                },limit:5
            )


    Template.top_buying_user.onRendered ->
        @autorun -> Meteor.subscribe 'users',5
    Template.top_buying_user.helpers
        top_buying_users: ->
            Meteor.users.find({},limit:5)



    Template.todays_schedule.onCreated ->
        @autorun -> Meteor.subscribe 'todays_reservations', Meteor.userId()
    Template.todays_schedule.helpers
        today_events: ->
            today_formatted = moment(Date.now()).format("MM-DD-YY")
            Docs.find({model:'shop'},limit:5)


    Template.todays_earnings.helpers
        todays_reservations: ->
            today_formatted = moment(Date.now()).format("MM-DD-YY")
            Docs.find(
                model:'reservation',
                date:today_formatted
                )

    Template.todays_earnings.events
        'click .recalculate_todays_earnings': ->
            console.log @
            Meteor.call 'recalculate_todays_earnings', Meteor.userId()


if Meteor.isServer
    Meteor.publish 'my_products', (user_id)->
        Docs.find
            model:'shop'
            _author_id:user_id
    Meteor.publish 'todays_reservations', (user_id)->
        user = Meteor.users.findOne user_id
        product_cursor = Docs.find(model:'shop',_author_id:user_id)
        # console.log 'product count', product_count
        product_ids = []
        for product in product_cursor.fetch()
            product_ids.push product._id
        today_formatted = moment(Date.now()).format("MM-DD-YY")

        Docs.find(
            model:'reservation',
            product_id:$in:product_ids
            date:today_formatted
            )

    Meteor.methods
        recalculate_todays_earnings: (user_id)->
            found_user = Meteor.users.findOne user_id
            # console.log found_user
            product_cursor = Docs.find(model:'shop',_author_id:Meteor.userId())
            # console.log 'product count', product_count
            product_ids = []
            for product in product_cursor.fetch()
                product_ids.push product._id
            # console.log 'prod ids', product_ids

            reservation_count = Docs.find(
                model:'reservation',
                product_id:$in:product_ids
                ).count()

            today_formatted = moment(Date.now()).format("MM-DD-YY")

            todays_reservation_count = Docs.find(
                model:'reservation',
                product_id:$in:product_ids
                date:today_formatted
                ).count()
            console.log 'reservation count', reservation_count
            console.log 'todays reservation count', todays_reservation_count

            Meteor.users.update user_id,
                $set:
                    current_product_count:product_cursor.count()
                    reservation_count:reservation_count
                    todays_reservation_count:todays_reservation_count