if Meteor.isClient
    Template.rentals.onCreated ->
        @autorun => Meteor.subscribe 'rentals',Router.current().params.doc_id

    Template.rentals.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.rentals.onCreated ->
        # @autorun -> Meteor.subscribe 'shop'
        @autorun -> Meteor.subscribe 'model_docs', 'reservation_slot'
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'shop'
    Template.rentals.helpers
        rentals: ->
            Docs.find
                model:'rental'
                product_id:Router.current().params.doc_id

        upcoming_days: ->
            upcoming_days = []
            now = new Date()
            today = moment(now).format('dddd MMM Do')
            # upcoming_days.push today
            day_number = 0
            for day in [0..6]
                day_number++
                moment_ob = moment(now).add(day, 'days')
                long_form = moment(now).add(day, 'days').format('dddd MMM Do')
                upcoming_days.push {moment_ob:moment_ob,long_form:long_form}
            upcoming_days

    Template.rentals.events
        'click .rent': ->
            new_id = Docs.insert
                model:'rental'
                product_id:Router.current().params.doc_id

    Template.upcoming_day.onCreated ->
        # console.log @data.data
        # @autorun => Meteor.subscribe 'reservation_slot', @data.data
        # @autorun => Meteor.subscribe 'reservation_slot', @data.data
        @autorun -> Meteor.subscribe 'model_docs', 'reservation_slot'
    Template.upcoming_day.helpers
        reservation_slot_exists: ->
            # console.log @valueOf()
            console.log moment(@data.moment_ob).format('MM-DD-YY')
            # @moment_ob.format('dddd MMM Do')
            Docs.findOne
                model:'reservation_slot'
                date:@data.moment_ob.format('MM-DD-YY')

        reservation_slot: ->
            # console.log @valueOf()
            console.log moment(@data.moment_ob).format('MM-DD-YY')
            # @moment_ob.format('dddd MMM Do')
            Docs.findOne
                model:'reservation_slot'
                date:@data.moment_ob.format('MM-DD-YY')

    Template.upcoming_day.events
        'click .new_slot': ->
            # moment_ob = @valueOf()
            # console.log @valueOf()
            # console.log @
            moment_ob = Template.parentData(1).moment_ob
            console.log moment_ob
            # console.log Template.parentData(2)
            console.log moment(moment_ob).format('MM-DD-YY')
            #
            Docs.insert
                model:'reservation_slot'
                date:moment_ob.format('MM-DD-YY')


    # chips placeholder
    # check weater pressure at chips place with pressure gauge on faucet


    Template.rental.events
        'click .delete_rental': ->
            Docs.remove @_id

        'click .calculate_diff': ->
            product = Template.parentData()
            console.log product
            moment_a = moment @start_datetime
            moment_b = moment @end_datetime
            rental_hours = -1*moment_a.diff(moment_b,'hours')
            rental_days = -1*moment_a.diff(moment_b,'days')
            hourly_rental_price = rental_hours*product.hourly_rate
            daily_rental_price = rental_days*product.daily_rate
            Docs.update @_id,
                $set:
                    'rental_hours':rental_hours
                    'rental_days':rental_days
                    hourly_rental_price:hourly_rental_price
                    daily_rental_price:daily_rental_price

if Meteor.isServer
    Meteor.publish 'rentals', (product_id)->
        Docs.find
            model:'rental'
            product_id:product_id
    Meteor.publish 'reservation_slot', (moment_ob)->
        rentals_return = []
        # for day in [0..6]
        #     day_number++
        #     # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
        #     date_stripg =  moment(now).add(day, 'days').format('YYYY-MM-DD')
        #     console.log date_stripg
        #     rentals.return.push date_stripg
        rentals_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'
