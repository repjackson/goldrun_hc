if Meteor.isClient
    FlowRouter.route '/buildings', action: ->
        BlazeLayout.render 'layout', 
            main: 'buildings'
            
            
    FlowRouter.route '/building/edit/:building_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_building'
    
    
    Template.buildings.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
        ), 500    

    
    Template.buildings.onCreated ->
        @autorun -> Meteor.subscribe('buildings')
   
    Template.edit_building.onCreated ->
        @autorun -> Meteor.subscribe('building', FlowRouter.getParam('building_id'))



    Template.buildings.helpers
        buildings: -> 
            Buildings.find {},
                sort: building_code: 1
         
                
    Template.buildings.events
        'click #add_building': ->
            id = Buildings.insert {}
            FlowRouter.go "/building/edit/#{id}"
    
    

    Template.edit_building.helpers
        building: -> 
            building_id = FlowRouter.getParam('building_id')
            # console.log building_id
            Buildings.findOne building_id 


    Template.edit_building.events
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
                Buildings.remove FlowRouter.getParam('building_id'), ->
                    FlowRouter.go "/buildings"



        'click #add_building_number': (e,t)->
            building_number = parseInt $('#new_building_number').val()
            Buildings.update @_id,
                $addToSet: 
                    building_numbers: building_number
            $('#new_building_number').val('')
        
        'keyup #new_building_number': (e,t)->
            if e.which is 13
                building_number = parseInt $('#new_building_number').val()
                Buildings.update @_id,
                    $addToSet: 
                        building_numbers: building_number
                $('#new_building_number').val('')
    
        'change #select_building_street': (e,t)->
            building_street = e.currentTarget.value
            Buildings.update @_id,
                $set: building_street: building_street

        'click .remove_number': (e,t)->
            building_number = @valueOf()
            Buildings.update FlowRouter.getParam('building_id'),
                $pull: 
                    building_numbers: building_number
            

if Meteor.isServer
    Buildings.allow
        insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        update: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
    
    Apartments.allow
        insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        update: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
    
    Meteor.publish 'buildings', ()->
        
        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Buildings.find match
    
    Meteor.publish 'building', (building_id)->
        Buildings.find building_id

    
