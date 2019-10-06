if Meteor.isClient
    Template.quick_res.helpers
        current_reservation: ->
            Docs.findOne Session.get('current_reservation_id')

        # upcoming_days: ->
        #     upcoming_days = []
        #     for day in [0..6]
        #         # day_number++
        #         # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
        #         date_string =  moment().add(day, 'days').format('YYYY-MM-DD')
        #         console.log date_string
        #         upcoming_days.push date_string
        #     upcoming_days

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

    Template.quick_res.events


    Template.upcoming_day.events
        'click .select_quick_res': ->
            Session.set('current_reservation_id', @_id)
            console.log @
        'click .reserve_slot': ->
            hour = @.valueOf()
            day_moment_ob = Template.parentData().moment_ob
            rental = Template.parentData(2)
            start_datetime = day_moment_ob.format("YYYY-MM-DD[T]#{hour}:00")
            start_date = day_moment_ob.format("YYYY-MM-DD")
            hour = parseInt(@.valueOf())

            new_quick_res = Docs.insert
                model:'reservation'
                rental_id: rental._id
                hour: hour
                start_date:start_date
                start_datetime: start_datetime
                status:'pending'
                complete:false
            Session.set('current_reservation_id', new_quick_res)

    Template.upcoming_day.helpers
        hours: -> [9..17]
        existing_res: ->
            day_moment_ob = Template.parentData().data.moment_ob
            start_date = day_moment_ob.format("YYYY-MM-DD")
            hour = parseInt(@.valueOf())
            Docs.findOne
                model:'reservation'
                hour: hour
                start_date: start_date


    Template.single_res.events
        'click .cancel_reservation': (e,t)->
            $(e.currentTarget).closest('.segment').transition('scale', 250)
            Meteor.setTimeout =>
                Docs.remove @_id
            , 250


if Meteor.isServer
    Meteor.publish 'incomplete_reservation', (rental_id)->
        Docs.find
            model:'reservation'
            rental_id: rental_id
            _author_id:Meteor.userId()
            complete:false
