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
            # if @read_by_ids
                # console.log @reader_ids
            # else
                # console.log 'no readers'
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


    Template.most_frequent_buyers.onRendered ->
        @autorun -> Meteor.subscribe 'users',5
    Template.most_frequent_buyers.helpers
        most_frequent_buyers: ->
            Meteor.users.find({},limit:5)


    Template.most_lucrative_buyers.onRendered ->
        @autorun -> Meteor.subscribe 'users',5
    Template.most_lucrative_buyers.helpers
        most_lucrative_buyers: ->
            Meteor.users.find({},limit:5)



    Template.todays_schedule.onCreated ->
        @autorun -> Meteor.subscribe 'todays_reservations', Meteor.userId()
    Template.todays_schedule.helpers
        today_events: ->
            today_formatted = moment(Date.now()).format("MM-DD-YY")
            Docs.find({model:'shop'},limit:5)


    Template.todays_stats.helpers
        todays_reservations: ->
            today_formatted = moment(Date.now()).format("MM-DD-YY")
            Docs.find(
                model:'reservation',
                date:today_formatted
                )

    Template.todays_stats.events
        'click .redraw_todays_stats': ->
            console.log @
            Meteor.call 'redraw_todays_stats', Meteor.userId()


    Template.weekly_stats.helpers
        todays_reservations: ->
            today_formatted = moment(Date.now()).format("MM-DD-YY")
            Docs.find(
                model:'reservation',
                date:today_formatted
                )
    Template.weekly_stats.events
        'click .redraw_weekly_stats': ->
            console.log @
            Meteor.call 'redraw_weekly_stats', Meteor.userId()


    Template.monthly_stats.helpers
        todays_reservations: ->
            today_formatted = moment(Date.now()).format("MM-DD-YY")
            Docs.find(
                model:'reservation',
                date:today_formatted
                )
    Template.monthly_stats.events
        'click .redraw_monthly_stats': ->
            console.log @
            Meteor.call 'redraw_monthly_stats', Meteor.userId()


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
        redraw_todays_stats: (user_id)->
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


        redraw_weekly_stats: (user_id)->
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

            week_ago = moment(Date.now()).subtract(1,'week')

            all_reservations_cursor =
                Docs.find(
                    model:'reservation',
                    product_id:$in:product_ids
                    # date:today_formatted
                    )

            weekly_reservations = 0
            weekly_earnings = 0
            for reservation in all_reservations_cursor.fetch()
                moment_date = moment(reservation.date)
                if moment_date.isAfter(week_ago) and moment_date.isBefore(Date.now())
                    product = Docs.findOne reservation.product_id
                    console.log 'hourly rate', product.hourly_rate
                    if parseInt(product.hourly_rate)>0
                        weekly_earnings += parseInt(product.hourly_rate)
                    weekly_reservations++
                else
                    console.log 'found before'


            console.log 'reservation count', weekly_reservations
            console.log 'weekly_earnings', weekly_earnings

            Meteor.users.update user_id,
                $set:
                    weekly_reservations:weekly_reservations
                    weekly_earnings:weekly_earnings
