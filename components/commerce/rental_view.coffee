if Meteor.isClient
    Template.kiosk_rental_view.events
        'click .new_reservation': ->
            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: @_id
            Router.go "/new_reservation/#{new_reservation_id}"
