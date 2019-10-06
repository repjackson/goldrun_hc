if Meteor.isClient
    Template.quick_res.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'bid'

    Template.quick_res.helpers
        current_hour: ->
            # Docs.findOne Session.get('current_hour')
            Session.get('current_hour')

        current_date: ->
            # Docs.findOne Session.get('current_hour')
            Session.get('current_date')

        hourly_bids: ->
            Docs.find
                model:'bid'


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


    Template.upcoming_day.events
        'click .select_hour': ->
            hour = parseInt(@.valueOf())
            Session.set('current_hour', hour)

            day_moment_ob = Template.parentData().moment_ob
            date = day_moment_ob.format("YYYY-MM-DD")
            Session.set('current_date', date)


    Template.upcoming_day.helpers
        hours: -> [9..17]
        hour_class: ->
            hour = parseInt(@.valueOf())
            day_moment_ob = Template.parentData().data.moment_ob
            date = day_moment_ob.format("YYYY-MM-DD")
            if Session.equals('current_hour', hour)
                if Session.equals('current_date', date)
                    'active'
        existing_bids: ->
            day_moment_ob = Template.parentData().data.moment_ob
            date = day_moment_ob.format("YYYY-MM-DD")
            hour = parseInt(@.valueOf())
            Docs.find
                model:'bid'
                hour: hour
                date: date


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
