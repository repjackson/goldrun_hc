FlowRouter.route '/events', action: (params) ->
    BlazeLayout.render 'layout',
        # cloud: 'event_cloud'
        main: 'events'

FlowRouter.route '/event/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_event'

FlowRouter.route '/event/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        # main: 'event_page'
        main: 'event_page'


@Events = new Meteor.Collection 'events'

Events.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    doc.points = 0
    doc.downvoters = []
    # doc.tags.push Meteor.user().profile.current_herd
    doc.upvoters = []
    return


# Events.after.insert (userId, doc)->
#     console.log doc.tags
#     return

Events.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tag_count = doc.tags?.length
    # Meteor.call 'generate_authored_cloud'
), fetchPrevious: true


Events.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()



if Meteor.isClient
    Template.events.onRendered ->
        # $('#event_slider').layerSlider
        #     autoStart: true
     
        
    Template.events.events
        'click #add_event': ->
            id = Events.insert {} 
            FlowRouter.go "/event/edit/#{id}"
    
    
    
    
    Template.events.onCreated -> @autorun -> Meteor.subscribe('selected_events', selected_tags.array())
    
    Template.upcoming_events.helpers
        upcoming_events: -> 
            today = new Date()
            today.setDate today.getDate() - 1
            # Events.find {start_date: $gte: today.toISOString()}, sort: start_date: 1
            Events.find { 
                reoccurring: $ne: true
                published: $ne: false
                start_datetime: $gte: today.toISOString()
                }, 
                sort: start_datetime: 1
    
    Template.admin_events.helpers
        admin_events: -> 
            Events.find { 
                published: false
                }
                
    Template.past_events.helpers
        past_events: -> 
            today = new Date()
            today.setDate today.getDate() - 1
            # Events.find {start_date: $lte: today.toISOString()}, sort: start_date: 1
            Events.find { 
                reoccurring: $ne: true
                published: $ne: false
                start_datetime: $lte: today.toISOString()
                }, 
                sort: start_datetime: 1
                limit: 10
                
    Template.reoccurring_events.helpers
        reoccurring_events: -> 
            today = new Date()
            # Events.find {start_date: $lte: today.toISOString()}, sort: start_date: 1
            Events.find { 
                reoccurring: true
                published: $ne: false
                # start_datetime: $gte: today.toISOString()
                }, 
                sort: start_datetime: 1
                
    
    Template.events.helpers
        options: ->
            # defaultView: 'basicWeek'
            defaultView: 'month'
    
    
    
    Template.event_card.helpers
        event_tag_class: -> if @valueOf() in selected_tags.array() then 'red' else 'basic'
    
        day: -> moment(@start_datetime).format("dddd, MMMM Do");
        start_time: -> moment(@start_datetime).format("h:mm a")
        end_time: -> moment(@end_datetime).format("h:mm a")
    
    
    Template.event_card.events
        # 'click .event_tag': ->
        #     if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()


if Meteor.isServer
    
    Events.allow
        insert: (userId, doc) -> doc.author_id is userId
        update: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')
    
    

    Meteor.publish 'featured_events', ->
        Events.find  {       
            featured: true
            }, 
            sort: start_date: -1
    
    
    # Meteor.publish 'upcoming_events', (selected_event_tags)->
    
    #     self = @
    #     match = {}
    #     if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
    
    #     today = Date.now()
    #     # match.start.local = $gt: today
    #     match["start.local"] = $lte: today
    
    #     console.log 'upcoming events match', match
    #     Events.find match,
    #         limit: 10
    #         # sort: 
    #         #     start_date: 1
    
    Meteor.publish 'selected_events', (selected_event_tags)->
        
        self = @
        match = {}
        # selected_event_tags.push 'academy'
    
        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Events.find match
    
    
    # Meteor.publish 'past_events', (selected_event_tags)->
    
    #     self = @
    #     match = {}
    #     if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        
    #     Events.find match,
    #         limit: 10
    #         # sort: 
    #         #     start_date: 1
    
    
    Meteor.publish 'all_events', ->
        Events.find()
    
    Meteor.publish 'event_tags', (selected_event_tags)->
        self = @
        match = {}
        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
    
    
        cloud = Events.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_event_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
    
        cloud.forEach (tag, i) ->
            self.added 'event_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
    
    