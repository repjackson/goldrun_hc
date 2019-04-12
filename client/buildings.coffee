if Meteor.isClient
    Router.route '/buildings', -> @render 'buildings'
    Router.route '/building/:doc_id/edit', -> @render 'building_edit'
    Router.route '/building/:doc_id/view', -> @render 'building_view'


    Template.buildings.onCreated ->
        @autorun -> Meteor.subscribe('type', 'building')

    Template.building_edit.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

    Template.building_view.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)



    Template.buildings.helpers
        buildings: ->
            Docs.find {type: 'building'}, sort:building_code:1

    Template.buildings.events
        'click #add_building': ->
            id = Docs.insert type: 'building'
            Router.go "/building/#{id}/edit"

    Template.building_edit.helpers
        building: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id

    Template.building_view.helpers
        building: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id


    Template.building_edit.events
        'click #delete_building': (e,t)->
            swal {
                title: 'Delete Building?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove Router.current().params.doc_id, ->
                    Router.go "/buildings"



        'click #add_building_number': (e,t)->
            building_number = parseInt $('#new_building_number').val()
            Docs.update @_id,
                $addToSet:
                    building_numbers: building_number
            $('#new_building_number').val('')

        'keyup #new_building_number': (e,t)->
            if e.which is 13
                building_number = parseInt $('#new_building_number').val()
                Docs.update @_id,
                    $addToSet:
                        building_numbers: building_number
                $('#new_building_number').val('')

        'change #select_building_street': (e,t)->
            building_street = e.currentTarget.value
            Docs.update @_id,
                $set: building_street: building_street

        'click .remove_number': (e,t)->
            building_number = @valueOf()
            Docs.update Router.current().params.doc_id,
                $pull:
                    building_numbers: building_number
