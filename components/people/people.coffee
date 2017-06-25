if Meteor.isClient
    FlowRouter.route '/people', action: ->
        BlazeLayout.render 'layout', 
            main: 'people'
            
            
    FlowRouter.route '/person/edit/:person_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_person'
    
    
    Template.people.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
        ), 500    
            
    
    Template.people.onCreated ->
        @autorun -> Meteor.subscribe('people')
   
    Template.edit_person.onCreated ->
        @autorun -> Meteor.subscribe('person', FlowRouter.getParam('person_id'))



    Template.people.helpers
        people: -> 
            People.find {}
                
    Template.people.events
        'click #add_person': ->
            id = People.insert {}
            FlowRouter.go "/person/edit/#{id}"
    
    

    Template.edit_person.helpers
        person: -> 
            person_id = FlowRouter.getParam('person_id')
            # console.log person_id
            People.findOne person_id 

        unassigned_roles: ->
            role_list = [
                'admin'
                'desk'
                'staff'
                'resident'
                'owner'
                'board'
                ]
            _.difference role_list, @roles


    Template.edit_person.events
        'click #delete_person': (e,t)->
            swal {
                title: 'Delete person?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                people.remove FlowRouter.getParam('person_id'), ->
                    FlowRouter.go "/people"


        'click .assign_role': ->
            People.update FlowRouter.getParam('person_id'),
                $addToSet: 
                    roles: @valueOf()
        'click .unassign_role': ->
            People.update FlowRouter.getParam('person_id'),
                $pull: 
                    roles: @valueOf()

        'blur #first_name': ->
            first_name = $('#first_name').val().trim()
            People.update FlowRouter.getParam('person_id'),
                $set: first_name: first_name

        'blur #last_name': ->
            last_name = $('#last_name').val().trim()
            People.update FlowRouter.getParam('person_id'),
                $set: last_name: last_name

        'blur #email': ->
            email = $('#email').val().trim()
            People.update FlowRouter.getParam('person_id'),
                $set: email: email

        'blur #phone': ->
            phone = $('#phone').val().trim()
            People.update FlowRouter.getParam('person_id'),
                $set: phone: phone

        'blur #company': ->
            company = $('#company').val().trim()
            People.update FlowRouter.getParam('person_id'),
                $set: company: company

        'blur #position': ->
            position = $('#position').val().trim()
            People.update FlowRouter.getParam('person_id'),
                $set: position: position





if Meteor.isServer
    People.allow
        insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        update: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
    
    
    Meteor.publish 'people', ()->
        
        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        People.find match
    
    Meteor.publish 'person', (person_id)->
        People.find person_id

    
