if Meteor.isClient
    FlowRouter.route '/frontdesk', action: ->
        BlazeLayout.render 'layout', 
            main: 'frontdesk'
            
            
    FlowRouter.route '/frontdesk/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_bike'
    
    
    
    Template.frontdesk.onCreated ->
        @autorun -> Meteor.subscribe('frontdesk')
    Template.edit_bike.onCreated ->
        @autorun -> Meteor.subscribe('bike', FlowRouter.getParam('doc_id'))

    
    Template.frontdesk.helpers
        frontdesk: -> 
            Docs.find 
                type: 'bike'
         
         
         
         
                
    Template.frontdesk.events
        'click #add_impounded_bike': ->
            id = Docs.insert
                type: 'bike'
            FlowRouter.go "/frontdesk/edit/#{id}"
    

    Template.edit_bike.helpers
        doc: -> 
            doc_id = FlowRouter.getParam 'doc_id'
            Docs.findOne  doc_id

    Template.edit_bike.events
        'click #delete_bike': ->
            swal {
                title: 'Delete?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, =>
                doc = Docs.findOne FlowRouter.getParam('doc_id')
                Docs.remove doc._id, ->
                    FlowRouter.go "/frontdesk"



if Meteor.isServer
    Meteor.publish 'frontdesk', ()->
        
        self = @
        match = {}
        match.type = 'bike'
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Docs.find match,
            limit: 10
            sort: 
                timestamp: -1
    
    Meteor.publish 'bike', (doc_id)->
        Docs.find doc_id

    
