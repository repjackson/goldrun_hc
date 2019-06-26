if Meteor.isClient
    Template.rentals.onCreated ->
        @autorun => Meteor.subscribe 'rentals',Router.current().params.doc_id

    Template.rentals.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.rentals.onCreated ->
        # @autorun -> Meteor.subscribe 'shop'
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'shop'
    Template.rentals.helpers
        rentals: ->
            Docs.find
                model:'rental'
                product_id:Router.current().params.doc_id

    Template.rentals.events
        'click .rent': ->
            new_id = Docs.insert
                model:'rental'
                product_id:Router.current().params.doc_id


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
