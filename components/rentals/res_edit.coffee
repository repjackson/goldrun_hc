if Meteor.isClient
    Router.route '/reservation/:doc_id/edit', (->
        @render 'reservation_edit'
        ), name:'reservation_edit'

    Template.reservation_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'owner_by_res_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'handler_by_res_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'user_by_username', 'deb_sclar'


    Template.key_value_edit.events
        'click .set_key_value': ->
            parent = Template.parentData()
            Docs.update parent._id,
                $set: "#{@key}": @value

    Template.key_value_edit.helpers
        set_key_value_class: ->
            parent = Template.parentData()
            # console.log parent
            if parent["#{@key}"] is @value then 'green' else ''


    Template.reservation_edit.helpers
        rental: -> Docs.findOne model:'rental'
        now_button_class: -> if @now then 'green' else ''
        sel_hr_class: -> if @duration_type is 'hour' then 'green' else ''
        sel_day_class: -> if @duration_type is 'day' then 'green' else ''
        sel_month_class: -> if @duration_type is 'month' then 'green' else ''
        is_month: -> @duration_type is 'month'
        is_day: -> @duration_type is 'day'
        is_hour: -> @duration_type is 'hour'
        member_balance_after_reservation: ->
            current_balance = Meteor.user().credit
            current_balance-@cost

        # diff: -> moment(@end_datetime).diff(moment(@start_datetime),'hours',true)

    Template.reservation_edit.events
        'change .res_start': (e,t)->
            val = t.$('.res_start').val()
            Docs.update @_id,
                $set:start_datetime:val

        'change .res_end': (e,t)->
            val = t.$('.res_end').val()
            Docs.update @_id,
                $set:end_datetime:val

            rental = Docs.findOne @rental_id
            hour_duration = moment(val).diff(moment(@start_datetime),'hours',true).toFixed(2)
            cost = parseFloat hour_duration*rental.hourly_dollars.toFixed(2)
            # console.log diff
            taxes_payout = parseFloat((cost*.05)).toFixed(2)
            owner_payout = parseFloat((cost*.5)).toFixed(2)
            handler_payout = parseFloat((cost*.45)).toFixed(2)
            Docs.update @_id,
                $set:
                    hour_duration: hour_duration
                    cost: cost
                    taxes_payout: taxes_payout
                    owner_payout: owner_payout
                    handler_payout: handler_payout

        'click .select_day': ->
            Docs.update @_id,
                $set: duration_type: 'day'
        'click .select_hour': ->
            Docs.update @_id,
                $set: duration_type: 'hour'
        'click .select_month': ->
            Docs.update @_id,
                $set: duration_type: 'month'

        'click .set_1_hr': ->
            Docs.update @_id,
                $set:
                    hour_duration: 1
                    end_datetime: moment(@start_datetime).add(1,'hour').format("YYYY-MM-DD[T]HH:mm")
            rental = Docs.findOne @rental_id
            hour_duration = 1
            cost = parseFloat hour_duration*rental.hourly_dollars.toFixed(2)
            # console.log diff
            taxes_payout = parseFloat((cost*.05)).toFixed(2)
            owner_payout = parseFloat((cost*.5)).toFixed(2)
            handler_payout = parseFloat((cost*.45)).toFixed(2)
            Docs.update @_id,
                $set:
                    cost: cost
                    taxes_payout: taxes_payout
                    owner_payout: owner_payout
                    handler_payout: handler_payout

        'change .other_hour': ->
            val = parseInt $('.other_hour').val()
            console.log val
            Docs.update @_id,
                $set:
                    hour_duration: val
                    end_datetime: moment(@start_datetime).add(val,'hour').format("YYYY-MM-DD[T]HH:mm")
            rental = Docs.findOne @rental_id
            hour_duration = val
            cost = parseFloat hour_duration*rental.hourly_dollars.toFixed(2)
            # console.log diff
            taxes_payout = parseFloat((cost*.05)).toFixed(2)
            owner_payout = parseFloat((cost*.5)).toFixed(2)
            handler_payout = parseFloat((cost*.45)).toFixed(2)
            Docs.update @_id,
                $set:
                    cost: cost
                    taxes_payout: taxes_payout
                    owner_payout: owner_payout
                    handler_payout: handler_payout

        'click .reserve_now': ->
            if @now
                Docs.update @_id,
                    $set:
                        now: false
            else
                now = Date.now()
                Docs.update @_id,
                    $set:
                        now: true
                        start_datetime: moment(now).format("YYYY-MM-DD[T]HH:mm")
                        start_timestamp: now

        'click .submit_reservation': ->
            if confirm "confirm payment of #{@cost} credit?"
                rental = Docs.findOne @rental_id
                # console.log @
                console.log @owner_payout
                console.log rental.owner_username
                console.log @handler_payout
                console.log rental.handler_username
                console.log @taxes_payout
                Docs.update @_id,
                    $set:
                        submitted:true
                        submitted_timestamp:Date.now()
                Meteor.users.update @_id,
                    $inc: credit: -@cost
                owner = Meteor.users.findOne username:rental.owner_username
                handler = Meteor.users.findOne username:rental.handler_username
                bank = Meteor.users.findOne username:'dev'

                Meteor.users.update Meteor.userId(),
                    $inc: credit: -@cost
                console.log "took #{@cost} from you"
                Meteor.users.update owner._id,
                    $inc: credit: @owner_payout
                console.log "gave #{@owner_payout} to #{owner.username}"
                Meteor.users.update handler._id,
                    $inc: credit: @handler_payout
                console.log "gave #{@handler_payout} to #{handler.username}"
                Meteor.users.update bank._id,
                    $inc: credit: @taxes_payout
                console.log "gave #{@taxes_payout} to the bank"

                Docs.insert
                    model:'log_event'
                    parent_id:Router.current().params.doc_id
                    log_type:'reservation_submission'
                    text:"reservation submitted by #{Meteor.user().username}"
                Router.go "/reservation/#{@_id}/view"

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
                Router.go "/rental/#{@rental_id}/view"
