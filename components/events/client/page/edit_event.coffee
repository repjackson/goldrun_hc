Template.edit_event.onCreated ->
    @autorun -> Meteor.subscribe 'event', FlowRouter.getParam('event_id')


Template.edit_event.helpers
    event: -> Events.findOne FlowRouter.getParam('event_id')
    

        
        
Template.edit_event.events
    'click #save_event': ->
        start_datetime = $('#start_datetime').val()
        end_datetime = $('#end_datetime').val()
        
        Events.update FlowRouter.getParam('event_id'),
            $set:
                start_datetime: start_datetime
                end_datetime: end_datetime

        FlowRouter.go "/event/view/#{@_id}"


    'blur #body': ->
        body = $('#body').val()
        Events.update FlowRouter.getParam('event_id'),
            $set:
                start_datetime: start_datetime
                end_datetime: end_datetime

        FlowRouter.go "/event/view/#{@_id}"
