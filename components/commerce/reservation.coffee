if Meteor.isClient
    Router.route '/kiosk_reservation_view/:doc_id', (->
        @layout 'mlayout'
        @render 'kiosk_reservation_view'
        ), name:'kiosk_reservation_view'
    Router.route '/reservations', (->
        @render 'reservations'
        ), name:'reservations'
    Router.route '/reservation/:doc_id/view', (->
        @render 'reservation_view'
        ), name:'reservation_view'
    Router.route '/reservation/:doc_id/edit', (->
        @render 'reservation_edit'
        ), name:'reservation_edit'


    # Template.kiosk_reservation_view.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.reservation_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.reservation_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # Template.reservations.onCreated ->
    #     @autorun -> Meteor.subscribe 'reservation_docs', selected_reservation_tags.array()
        # @autorun => Meteor.subscribe 'model_docs','reservation'
        # @autorun => Meteor.subscribe 'model_docs','reservation_slot'
        # @autorun -> Meteor.subscribe 'shop'
        # @autorun -> Meteor.subscribe 'model_docs', 'reservation_slot'
        # @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'shop'





    # Template.reservations.events
    #     'click .rent': ->
    #         new_id = Docs.insert
    #             model:'reservation'
    #             product_id:Router.current().params.doc_id


    #
    # Template.reservation_small.onCreated ->
    #     @autorun -> Meteor.subscribe 'model_docs', 'reservation'
    # Template.reservation_small.helpers
    #     reservations: ->
    #         Docs.find {
    #             model:'reservation'
    #         },
    #             sort: _timestamp: -1
    #             # limit:7
    #
    # Template.reservation_status.events
    #     'click .new_reservation': (e,t)->
    #         console.log @
    #         new_reservation_id = Docs.insert
    #             model:'reservation'
    #             reservation_id: @_id
    #         Router.go "/reservation/#{new_reservation_id}/edit"
    #
    #
    #


if Meteor.isServer
    Meteor.publish 'reservations', (product_id)->
        Docs.find
            model:'reservation'
            product_id:product_id
