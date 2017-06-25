if Meteor.isClient
    FlowRouter.route '/tasks', action: ->
        BlazeLayout.render 'layout', 
            main: 'tasks'
            
            
    FlowRouter.route '/task/edit/:task_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_task'
    
    
    
    
    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe('tasks')
    
    # Template.edit_task.onRendered ->
    #     Meteor.setTimeout (->
    #         $('select.dropdown').dropdown()
    #     ), 500

    Template.edit_task.onCreated ->
        @autorun -> Meteor.subscribe('task', FlowRouter.getParam('task_id'))
        @autorun -> Meteor.subscribe('buildings')
    
         
    Template.tasks.helpers
        tasks: -> 
            Tasks.find {},
                sort: tag_number: 1
         
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
            id = Tasks.insert {}
            FlowRouter.go "/task/edit/#{id}"
    
    Template.edit_task.helpers
        task: -> 
            task_id = FlowRouter.getParam('task_id')
            # console.log task_id
            Tasks.findOne task_id 


    Template.tag_number.events
        'blur #tag_number': (e,t)->
            tag_number = parseInt $(e.currentTarget).closest('#tag_number').val()
            Tasks.update @_id,
                $set: tag_number: tag_number
    
    
    Template.task_completed.helpers
        mark_true_class: -> if @task_completed then 'green' else 'basic'
        mark_false_class: -> if @task_completed then 'basic' else 'red'

    Template.task_completed.events
        'click #mark_true': (e,t)->
            Tasks.update @_id,
                $set: task_completed: true
        'click #mark_false': (e,t)->
            Tasks.update @_id,
                $set: task_completed: false
    

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
                Tasks.remove FlowRouter.getParam('task_id'), ->
                    FlowRouter.go "/tasks"

        'change #task_due_date': (e,t)->
            task_due_date = e.currentTarget.value
            Tasks.update @_id,
                $set: task_due_date: task_due_date



if Meteor.isServer
    Tasks.allow
        insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        update: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
    
    Meteor.publish 'tasks', ()->
        
        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Tasks.find match,
            limit: 10
            sort: 
                tag_number: -1
    
    Meteor.publish 'task', (task_id)->
        Tasks.find task_id

    
