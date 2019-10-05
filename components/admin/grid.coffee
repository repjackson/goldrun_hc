if Meteor.isClient
    Template.grid.onCreated ->
        # @autorun => Meteor.subscribe 'role_models', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'model'
        # @autorun => Meteor.subscribe 'role_models'
        # @autorun => Meteor.subscribe 'model_fields_from_child_id', Router.current().params.doc_id
        Session.set 'model_filter',null

    Template.grid.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.grid.events
        'click .set_model': ->
            Session.set 'loading', true
            if Meteor.user()
                Docs.update @_id,
                    $inc: views: 1
                    $addToSet:viewer_usernames:Meteor.user().username
            else
                Docs.update @_id,
                    $inc: views: 1
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false

        # 'click .grid_seg': ->
        #     Meteor.call 'increment_view', @_id, ->

        'keyup .model_filter': (e,t)->
            model_filter = $('.model_filter').val()
            if e.which is 8
                if model_filter.length is 0
                    Session.set 'model_filter',null
                else
                    Session.set 'model_filter',model_filter
            else
                Session.set 'model_filter',model_filter
        'mouseenter .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').addClass('raised')
        'mouseleave .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').removeClass('raised')

    Template.grid.helpers
        role_models: ->
            match = {model:'model'}
            if selected_tags.array().length > 0
                match.tags = $in:selected_tags.array()
            model_filter = Session.get('model_filter')
            if model_filter
                match.title = {$regex:"#{model_filter}", $options: 'i'}
            if Meteor.user()
                unless Meteor.user().roles and 'dev' in Meteor.user().roles
                    match.view_roles = $in:Meteor.user().roles
            else
                match.view_roles = $in:['public']
            Docs.find match,
                sort:views:-1
                limit:16

        model_filter_value: ->
            Session.get 'model_filter'


    Template.model_list_item_view.events
        'click .goto_doc': ->
            if @model is 'rental'
                Router.go "/rental/#{@_id}/view"
            else
                Router.go "/m/#{@model}/#{@_id}/view"

    Template.grid_role_model.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', @data.slug, 5
    Template.grid_role_model.helpers
        model_docs: ->
            Docs.find {
                model:@slug
            },
                sort:views:1
                limit:5




    Template.revenue_calculator.onCreated ->
        @autorun => Meteor.subscribe 'member_revenue_calculator_doc', Router.current().params.username
        @autorun => Meteor.subscribe 'simulated_rental_items', Router.current().params.username
    Template.revenue_calculator.events
        'click .recalc_revenue_stats': ->
            calc_doc = Docs.findOne model:'calculator_doc'
            total_daily_minutes_committed = 0
            daily_rentals = 0
            handled_rentals = 0
            totaled_daily_revenue = 0
            sim_rental_items = Docs.find(model:'simulated_rental_item').fetch()
            for item in sim_rental_items
                total_daily_minutes_committed += item.minutes_committed
                daily_rentals += item.rental_amount
                if item.handled
                    handled_rentals += item.rental_amount
                totaled_daily_revenue += item.calculated_daily_revenue
            total_weekly_hours_committed = parseInt((total_daily_minutes_committed*7/60)).toFixed(1)
            Docs.update calc_doc._id,
                $set:
                    total_daily_minutes_committed: total_daily_minutes_committed
                    total_weekly_hours_committed: total_weekly_hours_committed
                    total_weekly_rentals: daily_rentals*7
                    daily_rentals: daily_rentals
                    totaled_daily_revenue: totaled_daily_revenue
                    totaled_weekly_revenue: (totaled_daily_revenue*7).toFixed(2)
                    totaled_monthly_revenue: (totaled_daily_revenue*7*4.3).toFixed(2)
                    average_hourly_wage: (totaled_daily_revenue/(total_daily_minutes_committed/60)).toFixed(1)
                    total_neighbor_interactions: handled_rentals*2*7


        'click .create_simluated_item': ->
            calc_doc = Docs.findOne model:'calculator_doc'
            Docs.insert
                model:'simulated_rental_item'
                parent_id: calc_doc._id

    Template.simulated_rental_item.events
        'blur .rental_amount': (e,t)->
            val = parseInt $(e.currentTarget).closest('.rental_amount').val()
            minutes_committed =
                if @delivery then val*10
                else if @handled then val*5
                else 0
            Docs.update @_id,
                $set:
                    rental_amount:val
                    minutes_committed:minutes_committed
            Meteor.call 'calculate_daily_revenue', @_id

        'blur .average_hourly': (e,t)->
            val = parseFloat $(e.currentTarget).closest('.average_hourly').val()
            Docs.update @_id,
                $set:average_hourly:val
            Meteor.call 'calculate_daily_revenue', @_id

        'blur .daily_hours_rented': (e,t)->
            val = parseInt $(e.currentTarget).closest('.daily_hours_rented').val()
            Docs.update @_id,
                $set:daily_hours_rented:val
            Meteor.call 'calculate_daily_revenue', @_id


    Template.small_boolean_edit.helpers
        boolean_toggle_class: ->
            parent = Template.parentData()
            if parent["#{@key}"] then 'active' else ''


    Template.small_boolean_edit.events
        'click .toggle_boolean': (e,t)->
            parent = Template.parentData()
            $(e.currentTarget).closest('.button').transition('pulse', 100)
            Docs.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]




    Template.simulated_rental_item.helpers
        total_minutes_committed: ->
            minutes_committed = 0
            handled_amount = Docs.find(
                model:'simulated_rental_item'
                handled:true
            ).count()
            minutes_committed += handled_amount*10
            minutes_committed


        hourly_cut: ->
            hourly_cut = 0
            if @owned
                hourly_cut += .5
            if @handled
                hourly_cut += .45
            hourly_cut*100
    Template.revenue_calculator.helpers
        rental_amount: ->
            Docs.find(model:'simulated_rental_item').count()

        items: ->
            Docs.find
                model:'simulated_rental_item'

        calculator_doc: ->
            Docs.findOne
                model:'calculator_doc'



if Meteor.isServer
    Meteor.publish 'role_models', ()->
        match = {}
        match.model = 'model'
        if Meteor.user()
            unless 'dev' in Meteor.user().roles
                match.view_roles = $in:Meteor.user().roles
        Docs.find match
    Meteor.publish 'member_revenue_calculator_doc', (username)->
        match = {}
        match.model = 'calculator_doc'
        if Meteor.user()
            match.member_username = username
        else
            match.member_username = null
        calc_doc = Docs.findOne match
        unless calc_doc
            Docs.insert match
        Docs.find match
    Meteor.publish 'simulated_rental_items', (username)->
        match = {}
        match.model = 'calculator_doc'
        if Meteor.user()
            match.member_username = username
        else
            match.member_username = null
        calc_doc = Docs.findOne match
        unless calc_doc
            Docs.insert match
        calc_doc = Docs.find match
        if calc_doc
            Docs.find
                model:'simulated_rental_item'
                parent_id: calc_doc._id



    Meteor.methods
        calculate_daily_revenue: (sim_rental_item_id)->
            sim_rental_item = Docs.findOne sim_rental_item_id
            hourly_cut = 0
            if sim_rental_item.owned
                hourly_cut += .5
            if sim_rental_item.handled
                hourly_cut += .45
            res = parseInt((sim_rental_item.average_hourly*hourly_cut*sim_rental_item.daily_hours_rented))
            console.log res
            Docs.update sim_rental_item_id,
                $set:
                    calculated_daily_revenue: res
                    calculated_weekly_revenue: res*7
