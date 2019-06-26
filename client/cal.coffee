require 'dhtmlx-scheduler/codebase/dhtmlxscheduler.js';
require 'dhtmlx-scheduler/codebase/dhtmlxscheduler.css';

Template.cal.onCreated ->
    @autorun => Meteor.subscribe 'model_docs', 'event'
Template.user_diagram.onRendered ->
    myDiagram = new dhx.Diagram("diagram_container", {type:"org"});

Template.cal.onRendered ->
    container = @$('.dhx_cal_container')[0]
    scheduler.init container, new Date(), 'week'

    parseEventData = (data) ->
        event = {}
        for property of data
            # console.log property
            if property == '_id'
                event['id'] = data[property]
            else
                event[property] = data[property]
        event

    serializeEvent = (event) ->
        data = {model:'event'}
        for property of event
            if property.charAt(0) == '_' or property == 'id'
                continue
            data[property] = event[property]
        data

    eventsCursor = Docs.find(model:'event')
    events = []
    renderTimeout = null
    eventsCursor.observe
        added: (data) ->
            event = parseEventData(data)
            if !scheduler.getEvent(event.id)
                events.push event
            clearTimeout renderTimeout
            renderTimeout = setTimeout((->
                scheduler.parse events, 'json'
                events = []
            ), 5)
        changed: (data) ->
            event = parseEventData(data)
            originalEvent = scheduler.getEvent(event.id)
            console.log event
            console.log data
            if !originalEvent
                for key of event
                    originalEvent[key] = event[key]
            scheduler.updateView()
        removed: (data) ->
            event = parseEventData(data)
            if scheduler.getEvent(event.id)
                scheduler.deleteEvent event.id
    scheduler.attachEvent 'onEventAdded', (eventId, event) ->
        data = serializeEvent(event)
        # newId = Docs.insert(data)
        console.log data
        scheduler.changeEventId eventId, newId
    scheduler.attachEvent 'onEventChanged', (eventId, event) ->
        data = serializeEvent(event)
        Docs.update eventId, $set: data
    scheduler.attachEvent 'onEventDeleted', (eventId) ->
        Docs.remove eventId
