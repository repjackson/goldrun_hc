if Meteor.isClient
    Template.key_value_edit.events
        'click .set_key_value': ->
            console.log @
            parent = Template.parentData()
            Docs.update parent._id,
                $set: "#{@key}": @value

    Template.key_value_edit.helpers
        set_key_value_class: ->
            console.log @
            parent = Template.parentData()
            console.log parent
            if parent["#{@key}"] is @value then 'green' else ''




    Template.new_reservation.helpers
        estimated_cost: ->
            console.log @
            rental = Docs.findOne @rental_id
            if rental.hourly_rate
                rental.hourly_rate*@hour_duration


    Template.new_reservation.events
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
        'click .cancel_reservation': ->
            if confirm 'delete reservation?'
                Docs.remove @_id
                Router.go "/kiosk_rental_view/#{@rental_id}"
