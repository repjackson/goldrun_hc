if Meteor.isClient
    FlowRouter.route '/tasks', action: ->
        BlazeLayout.render 'layout', 
            main: 'tasks'
            
            
    FlowRouter.route '/task/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_task'
    
    
    
    
    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe('tasks')
    
    # Template.edit_task.onRendered ->
    #     Meteor.setTimeout (->
    #         $('select.dropdown').dropdown()
    #     ), 500

    Template.edit_task.onCreated ->
        @autorun -> Meteor.subscribe('task', FlowRouter.getParam('doc_id'))
        @autorun -> Meteor.subscribe('buildings')
    
         
    Template.tasks.helpers
        tasks: -> 
            Docs.find { type: 'task' }
         
    Template.edit_task.helpers
        buildings: ->
            Buildings.find()
         
        building_numbers: ->
            # console.log @
            building = Buildings.findOne building_code: @lock_building_code
            # console.log building
            if building then building.building_numbers
    
    
    Template.tasks.events
        'click #add_task': ->
            # alert 'hi'
            id = Docs.insert type:'task'
            FlowRouter.go "/task/edit/#{id}"
    
    Template.edit_task.helpers
        task: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 


    Template.tag_number.events
        'blur #tag_number': (e,t)->
            tag_number = parseInt $(e.currentTarget).closest('#tag_number').val()
            Docs.update @_id,
                $set: tag_number: tag_number
    
    

    Template.edit_task.events
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
                Docs.remove FlowRouter.getParam('doc_id'), ->
                    FlowRouter.go "/tasks"


if Meteor.isServer
    Meteor.publish 'tasks', ()->
        
        self = @
        match = {}
        match.type = 'task'
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Docs.find match
    
    Meteor.publish 'task', (doc_id)->
        Docs.find doc_id

    
