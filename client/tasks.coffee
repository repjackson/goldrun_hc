if Meteor.isClient
    Router.route '/tasks', -> @render 'tasks'
    Router.route '/task/:doc_id/edit', -> @render 'task_edit'
    Router.route '/task/:doc_id/view', -> @render 'task_view'


    # Template.task.onRendered ->
    #     Meteor.setTimeout (->
    #         $('.shape').shape()
    #     ), 500


    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'task'

    Template.tasks.onRendered ->
        # Meteor.setTimeout (->
        #     $('table').tablesort()
        #     # $('select.dropdown').dropdown()
        # ), 500



    Template.task_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'docs', [], 'building'


    Template.tasks.helpers
        tasks: -> Docs.find { type: 'task' }

    Template.task_edit.helpers
        buildings: ->
            Docs.find type: 'building'

        building_numbers: ->
            # console.log @
            building = Docs.findOne
                building_code: @lock_building_code
                type: 'building'
            # console.log building
            if building then building.building_numbers


    Template.tasks.events
        'click #add_task': ->
            id = Docs.insert type:'task'
            Router.go "/task/#{id}/edit"

    Template.task.events
        'click .flip_shape': (e,t)->
            $(e.currentTarget).closest('.shape').shape('flip over');
            # console.log $(e.currentTarget).closest('.shape').shape('flip up')
            # $('.shape').shape('flip up')


    Template.task_edit.helpers
        task: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id



    Template.task_edit.events
        'click #delete_task': (e,t)->
            swal {
                title: 'Delete task?'
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
                    Router.go "/tasks"
