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

if Meteor.isServer
    Meteor.publish 'rentals', (product_id)->
        Docs.find
            model:'rental'
            product_id:product_id
