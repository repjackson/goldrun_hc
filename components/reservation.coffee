if Meteor.isClient
    Template.reservation_slot_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'reservation_slot_product', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'reservation_slot_reservation', Router.current().params.doc_id

    Template.reservation_slot_view.helpers
        reservation_slot:->
            Docs.findOne Router.current().params.doc_id
        reservation:->
            Docs.findOne model:'reservation'

        reservation_product:->
            slot = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                model:'shop'
                # _id:slot.product_id



    Template.reservation_slot_view.events
        'click .confirm_delivery': ->
            if confirm 'confirm delivery?'
                console.log 'your credits', Meteor.user().credits
                console.log 'seller credits', Meteor.users.findOne(@_author_id)
                Docs.update @_id,
                    $set:
                        confirmed:true

        'click .cancel_reservation': ->
            Docs.update @_id,
                $set:
                    confirmed:false

        'click .mark_delivery_started': ->
            if confirm 'mark delivery started?'
                Docs.update @_id,
                    $set:
                        delivery_started_timestamp:Date.now()
                        status:'delivery started'
                        delivery_started:true

        'click .new_reservation': ->
            slot = Docs.findOne model:'reservation_slot'
            Docs.insert
                model:'reservation'
                parent_slot:slot._id
                date:slot.date
            console.log Template.parentData()

        'click .mark_delivered': ->
            console.log @
            if confirm 'mark delivery ended?'
                Docs.update @_id,
                    $set:
                        delivery_ended_timestamp:Date.now()
                        status:'delivery ended'
                        delivery_ended:true

        'click .mark_complete': ->
            if confirm 'mark reservation ended?'
                Docs.update @_id,
                    $set:
                        reservation_ended_timestamp:Date.now()
                        status:'reservation marked complete'
                        reservation_ended:true


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
