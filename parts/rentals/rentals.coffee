Router.route '/rentals/', (->
    @layout 'layout'
    @render 'rentals'
    ), name:'rentals'

if Meteor.isClient
    Template.rentals.onRendered ->
        @autorun -> Meteor.subscribe 'rental_docs', selected_rental_tags.array()
    Template.rentals.events
        'click .add_rental': ->
            new_rental_id =
                Docs.insert
                    model:'rental'
            Router.go "/rental/#{new_rental_id}/edit"

    Template.rentals.helpers
        rentals: ->
            Docs.find
                model:'rental'
