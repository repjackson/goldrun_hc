if Meteor.isClient
    Router.route '/people', action: ->
        BlazeLayout.render 'layout', 
            main: 'people'
            
            
    Router.route '/person/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_person'
    
    Router.route '/person/view/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'person_page'
    
    
    Template.people.onCreated ->
        @autorun -> Meteor.subscribe('docs', [], 'person')
   
    Template.edit_person.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.getParam('doc_id'))

    Template.person_page.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.getParam('doc_id'))



    Template.people.helpers
        people: -> 
            # People.find {}
            Docs.find
                type: 'person'
                
    Template.people.events
        'click #add_person': ->
            id = Docs.insert type:'person'
            Router.go "/person/edit/#{id}"
    

    Template.person_page.helpers
        person: -> 
            doc_id = Router.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 
    
    Template.edit_person.helpers
        person: -> 
            doc_id = Router.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 

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
                Docs.remove Router.getParam('doc_id'), ->
                    Router.go "/people"


        'click .assign_role': ->
            Docs.update Router.getParam('doc_id'),
                $addToSet: 
                    roles: @valueOf()
        'click .unassign_role': ->
            Docs.update Router.getParam('doc_id'),
                $pull: 
                    roles: @valueOf()

        'blur #first_name': ->
            first_name = $('#first_name').val().trim()
            Docs.update Router.getParam('doc_id'),
                $set: first_name: first_name

        'blur #last_name': ->
            last_name = $('#last_name').val().trim()
            Docs.update Router.getParam('doc_id'),
                $set: last_name: last_name

        'blur #email': ->
            email = $('#email').val().trim()
            Docs.update Router.getParam('doc_id'),
                $set: email: email

        'blur #phone': ->
            phone = $('#phone').val().trim()
            Docs.update Router.getParam('doc_id'),
                $set: phone: phone

        'blur #company': ->
            company = $('#company').val().trim()
            Docs.update Router.getParam('doc_id'),
                $set: company: company

        'blur #position': ->
            position = $('#position').val().trim()
            Docs.update Router.getParam('doc_id'),
                $set: position: position