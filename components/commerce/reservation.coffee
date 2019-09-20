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
        @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id
    Template.reservation_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id



    Template.reservation_edit.helpers
        estimated_cost: ->
            console.log @
            rental = Docs.findOne @rental_id
            if rental.hourly_rate
                rental.hourly_rate*@hour_duration
    Template.reservation_edit.events
        'click .submit_reservation': ->
            rental = Docs.findOne @rental_id
            if rental.hourly_rate
                estimated_cost = rental.hourly_rate*@hour_duration
            Docs.update @_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
                    estimated_cost:estimated_cost
            Docs.insert
                model:'log_event'
                parent_id:Router.current().params.doc_id
                log_type:'reservation_submission'
                text:"reservation submitted by #{Meteor.user().username}"
            # Router.go "/reservation/#{@_id}/view"

        'click .unsubmit': ->
            Docs.update @_id,
                $set:
                    submitted:false
                    unsubmitted_timestamp:Date.now()
            Docs.insert
                model:'log_event'
                parent_id:Router.current().params.doc_id
                log_type:'reservation_unsubmission'
                text:"reservation unsubmitted by #{Meteor.user().username}"
            # Router.go "/reservation/#{@_id}/view"



    Template.reservation_events.onCreated ->
        @autorun => Meteor.subscribe 'log_events', Router.current().params.doc_id
    Template.reservation_events.helpers
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id






if Meteor.isServer
    Meteor.publish 'log_events', (parent_id)->
        Docs.find
            model:'log_event'
            parent_id:parent_id

    Meteor.publish 'reservations_by_product_id', (product_id)->
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'rental_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        if reservation
            Docs.find
                model:'rental'
                _id: reservation.rental_id

    Meteor.methods
        calc_reservation_stats: ->
            reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            unless reservation_stat_doc
                new_id = Docs.insert
                    model:'reservation_stats'
                reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            console.log reservation_stat_doc
            total_count = Docs.find(model:'reservation').count()
            submitted_count = Docs.find(model:'reservation', submitted:true).count()
            current_count = Docs.find(model:'reservation', current:true).count()
            unsubmitted_count = Docs.find(model:'reservation', submitted:$ne:true).count()
            Docs.update reservation_stat_doc._id,
                $set:
                    total_count:total_count
                    submitted_count:submitted_count
                    current_count:current_count
