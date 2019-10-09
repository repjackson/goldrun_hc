if Meteor.isClient
    Template.rental_calendar.onCreated ->
        @autorun => Meteor.subscribe 'rental_bids', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'rental_reservations_by_id', Router.current().params.doc_id

    Template.rental_calendar.helpers
        rental: -> Docs.findOne Router.current().params.doc_id

        current_hour: ->
            # Docs.findOne Session.get('current_hour')
            Session.get('current_hour')
        current_date_string: ->
            # Docs.findOne Session.get('current_hour')
            Session.get('current_date_string')
        current_date: ->
            # Docs.findOne Session.get('current_hour')
            Session.get('current_date')

        current_month: ->
            # Docs.findOne Session.get('current_hour')
            Session.get('current_month')

        has_bid: ->
            Docs.findOne
                model:'bid'
                hour: Session.get('current_hour')
                date:Session.get('current_date')
                _author_id: Meteor.userId()

        hourly_bids: ->
            Docs.find {
                model:'bid'
                hour: Session.get('current_hour')
                date:Session.get('current_date')
            }, sort:bid_amount:-1
        hourly_reservations: ->
            # day_moment_ob = Template.parentData().data.moment_ob
            # # start_date = day_moment_ob.format("YYYY-MM-DD")
            # start_date = day_moment_ob.date()
            # start_month = day_moment_ob.month()
            # start_hour = parseInt(@.valueOf())
            start_date = parseInt Session.get('current_date')
            start_hour = parseInt Session.get('current_hour')
            start_month = parseInt Session.get('current_month')
            Docs.find {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }

        upcoming_days: ->
            upcoming_days = []
            now = new Date()
            today = moment(now).format('dddd MMM Do')
            # upcoming_days.push today
            day_number = 0
            # for day in [0..3]
            for day in [0..1]
                day_number++
                moment_ob = moment(now).add(day, 'days')
                long_form = moment(now).add(day, 'days').format('dddd MMM Do')
                upcoming_days.push {moment_ob:moment_ob,long_form:long_form}
            upcoming_days

    Template.rental_calendar.events
        'click .new_bid': ->
            hour = @.valueOf()
            # day_moment_ob = Template.parentData().moment_ob
            rental = Docs.findOne Router.current().params.doc_id
            # rental = Template.parentData(2)
            # start_datetime = day_moment_ob.format("YYYY-MM-DD[T]#{hour}:00")
            # start_date = day_moment_ob.format("YYYY-MM-DD")
            # hour = parseInt(@.valueOf())

            new_bid_id = Docs.insert
                model:'bid'
                rental_id: rental._id
                hour: Session.get('current_hour')
                date:Session.get('current_date')
                # start_datetime: start_datetime
                accepted:false

        'click .reserve_this': ->
            rental = Docs.findOne Router.current().params.doc_id
            current_month = parseInt Session.get('current_month')
            current_date = parseInt Session.get('current_date')
            current_minute = parseInt Session.get('current_minute')
            current_date_string = Session.get('current_date_string')
            current_hour = parseInt Session.get('current_hour')
            start_datetime = "#{current_date_string}T#{current_hour}:00"
            start_time = "#{current_hour}:00"
            end_time = moment(@start_datetime).add(1,'hours').format("HH:mm")

            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: rental._id
                start_hour: current_hour
                start_minute: 0
                start_date_string: current_date_string
                start_date: current_date
                start_month: current_month
                start_datetime: start_datetime
                start_time: start_time
                end_time: end_time
                hour_duration: 1

    Template.reservation_small.helpers
        is_paying: -> Session.get 'paying'
        can_buy: -> Meteor.user().credit > @total_cost
        need_credit: -> Meteor.user().credit < @total_cost
        need_approval: -> @friends_only and Meteor.userId() not in @author.friend_ids
        submit_button_class: -> if @start_datetime and @end_datetime then '' else 'disabled'
        member_balance_after_reservation: ->
            rental = Docs.findOne @rental_id
            if rental
                current_balance = Meteor.user().credit
                (current_balance-@total_cost).toFixed(2)

    Template.reservation_small.onCreated ->
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # product = Docs.findOne Router.current().params.doc_id
                # deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))*100
                # stripe_charge = parseInt(deposit_amount*1.02+20)
                # calculated_amount = deposit_amount*100
                # console.log calculated_amount
                deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
                stripe_charge = parseFloat(deposit_amount)*100
                console.log 'deposit_amount', deposit_amount
                console.log 'stripe charge', stripe_charge

                charge =
                    amount: stripe_charge
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, Meteor.user(), (error, response)=>
                    if error then alert error.reason, 'danger'
                    else
                        alert 'payment received', 'success'
                        Docs.insert
                            model:'payment'
                            deposit_amount:deposit_amount
                            stripe_charge:stripe_charge
                            amount_with_bonus:deposit_amount*1.05/100
                            bonus:deposit_amount*.05/100
                        Meteor.users.update Meteor.userId(),
                            $inc: credit: deposit_amount*1.05
    	)


    Template.reservation_small.events
        'click .add_credit': ->
            deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
            stripe_charge = parseFloat(deposit_amount)*100*1.02+20
            # stripe_charge = parseInt(deposit_amount*1.02+20)

            if confirm "add #{deposit_amount} credit?"
                Template.instance().checkout.open
                    name: 'credit deposit'
                    # email:Meteor.user().emails[0].address
                    description: 'gold run'
                    amount: stripe_charge

        'click .trigger_recalc': ->
            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id
            $('.handler')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })
            $('.result')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })

        'change .res_start_time': (e,t)->
            val = t.$('.res_start_time').val()
            Docs.update @_id,
                $set:start_time:val
            Meteor.call 'recalc_reservation_cost', Template.parentData().doc_id

        'change .res_end_time': (e,t)->
            val = t.$('.res_end_time').val()
            Docs.update @_id,
                $set:end_time:val
            Meteor.call 'recalc_reservation_cost', Template.parentData().doc_id

        'change .hour_duration': (e,t)->
            val = parseFloat(t.$('.hour_duration').val())
            console.log val
            console.log moment(@start_datetime).add(val,'hours').format("HH:mm")
            end_time = moment(@start_datetime).add(val,'hours').format("HH:mm")
            end_datetime = moment(@start_datetime).add(val,'hours').format("YYYY-MM-DD[T]HH:00")
            console.log end_datetime
            Docs.update @_id,
                $set:
                    hour_duration:val
                    end_time:end_time
                    end_datetime:end_datetime
            Meteor.call 'recalc_reservation_cost', @_id

        'change .res_start': (e,t)->
            val = t.$('.res_start').val()
            Docs.update @_id,
                $set:start_datetime:val
            Meteor.call 'recalc_reservation_cost', @_id

        'change .res_end': (e,t)->
            val = t.$('.res_end').val()
            Docs.update @_id,
                $set:end_datetime:val
            Meteor.call 'recalc_reservation_cost', @_id

        'click .submit_reservation': ->
            $('.ui.modal')
            .modal({
                closable: true
                onDeny: ()->
                onApprove: ()=>
                    # Session.set 'paying', true
                    rental = Docs.findOne @rental_id
                    # console.log @
                    Docs.update @_id,
                        $set:
                            submitted:true
                            submitted_timestamp:Date.now()
                    Session.set 'paying', false
                    Meteor.call 'pay_for_reservation', @_id, =>
                        Session.set 'paying', true
                        Router.go "/reservation/#{@_id}/view"
            }).modal('show')




    Template.upcoming_day.events
        'click .select_hour': ->
            day_moment_ob = Template.parentData().moment_ob

            hour = parseInt(@.valueOf())
            Session.set('current_hour', hour)

            date_string = day_moment_ob.format("YYYY-MM-DD")
            Session.set('current_date_string', date_string)


            date = day_moment_ob.date()
            Session.set('current_date', date)

            month = day_moment_ob.month()
            Session.set('current_month', month)

    Template.upcoming_day.helpers
        hours: -> [9..17]
        hour_class: ->
            classes = ''
            hour = parseInt(@.valueOf())
            day_moment_ob = Template.parentData().data.moment_ob
            # date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            found_res = Docs.findOne {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }
            if found_res and found_res.submitted
                classes += 'disabled'
            date = day_moment_ob.date()
            if Session.equals('current_hour', hour)
                if Session.equals('current_date', date)
                    classes += ' raised blue'
            classes
        pending_res: ->
            hour = parseInt(@.valueOf())
            day_moment_ob = Template.parentData().data.moment_ob
            # date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            found_res = Docs.findOne {
                model:'reservation'
                submitted: $ne: true
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }
        existing_bids: ->
            day_moment_ob = Template.parentData().data.moment_ob
            # date = day_moment_ob.format("YYYY-MM-DD")
            date = day_moment_ob.date()
            hour = parseInt(@.valueOf())
            Docs.find {
                model:'bid'
                hour: hour
                date: date
            }, sort:bid_amount:-1

        existing_reservations: ->
            day_moment_ob = Template.parentData().data.moment_ob
            # start_date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            Docs.find {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }


        is_top: ->
            # day_moment_ob = Template.parentData().data.moment_ob
            # date = day_moment_ob.format("YYYY-MM-DD")
            # hour = parseInt(@.valueOf())

            top = Docs.findOne({
                model:'bid'
                hour: @hour
                date: @date
            },
                sort:bid_amount:-1
                limit:1)
            if @_id is top._id
                true
            else
                false



    Template.single_bid.helpers
        bid_class: ->
            top = Docs.findOne({
                model:'bid'
                hour: @hour
                date: @date
            },
                sort:bid_amount:-1
                limit:1)
            if @_id is top._id then 'green' else ''


    Template.single_bid.events
        'click .cancel_bid': (e,t)->
            $(e.currentTarget).closest('.segment').transition('scale', 250)
            Meteor.setTimeout =>
                Docs.remove @_id
            , 250



if Meteor.isServer
    Meteor.publish 'day_bids', (rental_id, day)->
        Docs.find
            model:'bid'
            rental_id: rental_id
            _author_id:Meteor.userId()
            day: day

    Meteor.publish 'rental_bids', (rental_id)->
        Docs.find
            model:'bid'
            rental_id: rental_id
