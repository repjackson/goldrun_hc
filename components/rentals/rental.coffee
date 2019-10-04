if Meteor.isClient
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'
    Router.route '/rental/:doc_id/view', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'


    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_view.onRendered ->
        # console.log @
        Meteor.call 'increment_view', @data._id, ->



    # Template.rental.events
    #     'click .delete_rental': ->
    #         Docs.remove @_id
    #     'click .calculate_diff': ->
    #         product = Template.parentData()
    #         console.log product
    #         moment_a = moment @start_datetime
    #         moment_b = moment @end_datetime
    #         reservation_hours = -1*moment_a.diff(moment_b,'hours')
    #         reservation_days = -1*moment_a.diff(moment_b,'days')
    #         hourly_reservation_price = reservation_hours*product.hourly_rate
    #         daily_reservation_price = reservation_days*product.daily_rate
    #         Docs.update @_id,
    #             $set:
    #                 reservation_hours:reservation_hours
    #                 reservation_days:reservation_days
    #                 hourly_reservation_price:hourly_reservation_price
    #                 daily_reservation_price:daily_reservation_price


    Template.reserve_button.events
        'click .new_reservation': (e,t)->
            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: @_id
            Router.go "/reservation/#{new_reservation_id}/edit"


    Template.rental_view_reservations.onCreated ->
        @autorun -> Meteor.subscribe 'rental_reservations', Template.currentData()
    Template.rental_view_reservations.helpers
        reservations: ->
            Docs.find
                model:'reservation'




if Meteor.isServer
    Meteor.publish 'rental_reservations', (rental)->
        Docs.find
            model:'reservation'
            rental_id: rental._id

    Meteor.publish 'rentals', (product_id)->
        Docs.find
            model:'rental'
            product_id:product_id

    Meteor.publish 'reservation_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
        # for reservation in reservations
            # console.log 'id', reservation._id
            # console.log reservation.paid_amount
        Docs.find
            model:'reservation'
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
