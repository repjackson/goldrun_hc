if Meteor.isClient
    Template.reservation_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'reservation_slot_product', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'reservation_slot_reservation', Router.current().params.doc_id

    Template.reservation_view.helpers
        reservation_slot:->
            Docs.findOne Router.current().params.doc_id
        reservation:->
            Docs.findOne model:'reservation'

        reservation_product:->
            slot = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                model:'shop'
                # _id:slot.product_id



    Template.reservation_product_template.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.reservation_product_template.helpers
        s: ->
            console.log @
        reservation_product:->
            Docs.findOne Router.current().params.doc_id

if Meteor.isServer
    Meteor.publish 'reservation_slot_product', (slot_id)->
        slot = Docs.findOne slot_id
        Docs.find
            model:'shop'
            _id:slot.product_id

    Meteor.publish 'reservation_slot_reservation', (slot_id)->
        slot = Docs.findOne slot_id
        console.log 'slot', slot
        res = Docs.find(
            model:'reservation'
            parent_slot:slot._id
            )
        console.log res.fetch()
        return res
