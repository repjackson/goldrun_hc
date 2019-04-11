if Meteor.isClient
    Router.route '/work_orders', -> @render 'work_orders'
    Router.route '/work_order/:doc_id/edit', -> @render 'work_order_edit'
    Router.route '/work_order/:doc_id/view', -> @render 'work_order_view'


    # Template.work_order.onRendered ->
    #     Meteor.setTimeout (->
    #         $('.shape').shape()
    #     ), 500


    Template.work_orders.onCreated ->
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'work_order'

    Template.work_orders.onRendered ->
        # Meteor.setTimeout (->
        #     $('table').tablesort()
        #     # $('select.dropdown').dropdown()
        # ), 500



    Template.work_order_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'docs', [], 'building'


    Template.work_orders.helpers
        work_orders: -> Docs.find { type: 'work_order' }

    Template.work_order_edit.helpers
        buildings: ->
            Docs.find type: 'building'

        building_numbers: ->
            # console.log @
            building = Docs.findOne
                building_code: @lock_building_code
                type: 'building'
            # console.log building
            if building then building.building_numbers


    Template.work_orders.events
        'click #add_work_order': ->
            id = Docs.insert type:'work_order'
            Router.go "/work_order/#{id}/edit"



    Template.work_order_edit.events
        'click #delete_work_order': (e,t)->
            swal {
                title: 'Delete work_order?'
                text: 'Cannot be undone.'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove Router.current().params.doc_id, ->
                    Router.go "/work_orders"
