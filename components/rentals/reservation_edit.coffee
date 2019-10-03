if Meteor.isClient
    Router.route '/reservation/:doc_id/edit', (->
        @render 'reservation_edit'
        ), name:'reservation_edit'


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
        now_button_class: -> if @now then 'green' else ''
        sel_hr_class: -> if @duration_type is 'hour' then 'green' else ''
        sel_day_class: -> if @duration_type is 'day' then 'green' else ''
        sel_month_class: -> if @duration_type is 'month' then 'green' else ''
        is_month: -> @duration_type is 'month'
        is_day: -> @duration_type is 'day'
        is_hour: -> @duration_type is 'hour'
        member_balance_after_reservation: ->
            current_balance = Meteor.user().credit
            current_balance-@estimated_dollars

        # diff: -> moment(@end_datetime).diff(moment(@start_datetime),'hours',true)

    Template.reservation_edit.events
        'click .select_day': ->
            Docs.update @_id,
                $set: duration_type: 'day'
        'click .select_hour': ->
            Docs.update @_id,
                $set: duration_type: 'hour'
        'click .select_month': ->
            Docs.update @_id,
                $set: duration_type: 'month'

        'click .calculate_diff': ->
            rental = Docs.findOne @rental_id

            hour_duration = moment(@end_datetime).diff(moment(@start_datetime),'hours',true).toFixed(2)
            minute_duration = moment(@end_datetime).diff(moment(@start_datetime),'minutes',true).toFixed(2)
            estimated_dollars = hour_duration*rental.hourly_dollars.toFixed(2)
            # console.log diff
            taxes_payout = (estimated_dollars*.1).toFixed(2)
            owner_payout = (estimated_dollars*.5).toFixed(2)
            handler_payout = (estimated_dollars*.4).toFixed(2)
            Docs.update @_id,
                $set:
                    hour_duration: hour_duration
                    minute_duration: minute_duration
                    estimated_dollars: estimated_dollars
                    taxes_payout: taxes_payout
                    owner_payout: owner_payout
                    handler_payout: handler_payout



        # 'click .set_1_hr': ->
        #     Docs.update @_id,
        #         $set: hour_duration: 1
        #     end_time = moment(@start_datetime).add(1,'hour').format("kk:mm")
        #     end_date = moment(@start_datetime).add(1,'hour').format("YYYY-MM-DD")
        #     Docs.update @_id,
        #         $set:
        #             end_date: end_date
        #             end_time: end_time
        #             end_datetime: moment(@start_datetime).add(1,'hour')



        # 'click .reserve_now': ->
        #     if @now
        #         Docs.update @_id,
        #             $set:
        #                 now: false
        #     else
        #         now = Date.now()
        #         date = moment(now).subtract(6,'hours').format("YYYY-MM-DD")
        #         time = moment(now).subtract(6,'hours').format("kk:mm")
        #         Docs.update @_id,
        #             $set:
        #                 now: true
        #                 start_date: date
        #                 start_time: time
        #                 start_datetime: moment(now).subtract(6,'hours')
        #                 start_timestamp: now

        'click .submit_reservation': ->
            if confirm 'confirm payment?'
                rental = Docs.findOne @rental_id
                # console.log @
                console.log @owner_payout
                console.log @owner_username
                console.log @handler_payout
                console.log @handler_username
                console.log @taxes_payout
                console.log @taxes_username
                # Docs.update @_id,
                #     $set:
                #         submitted:true
                #         submitted_timestamp:Date.now()
                #         estimated_cost:estimated_cost
                #
                # Docs.insert
                #     model:'log_event'
                #     parent_id:Router.current().params.doc_id
                #     log_type:'reservation_submission'
                #     text:"reservation submitted by #{Meteor.user().username}"
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
                Router.go "/rental/#{@rental_id}/view"
