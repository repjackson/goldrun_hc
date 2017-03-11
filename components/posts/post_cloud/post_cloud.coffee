if Meteor.isClient
    
    @selected_post_tags = new ReactiveArray []

    
    Template.post_cloud.onCreated ->
        @autorun -> Meteor.subscribe('post_tags', selected_post_tags.array())
        @autorun -> Meteor.subscribe 'me'
    
    
    Template.post_cloud.helpers
        post_tags: ->
            post_count = Posts.find().count()
            if 0 < post_count < 3 then Tags.find { count: $lt: post_count } else Tags.find()
    
        cloud_tag_class: ->
            button_class = switch
                when @index <= 5 then 'large'
                when @index <= 12 then ''
                when @index <= 20 then 'small'
            return button_class
    
        selected_post_tags: -> selected_post_tags.array()
    
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Tags
                    field: 'name'
                    matchAll: true
                    template: Template.tag_result
                }
                ]
        }
    
    
    
    Template.post_cloud.events
        'click .select_tag': -> selected_post_tags.push @name
        'click .unselect_tag': -> selected_post_tags.remove @valueOf()
        'click #clear_tags': -> selected_post_tags.clear()
    
    
        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_post_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_post_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_post_tags.pop()
                        
        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            selected_post_tags.push doc.name
            $('#search').val ''


if Meteor.isServer
    Meteor.publish 'post_tags', (selected_post_tags)->
        
        self = @
        match = {}
        
        if selected_post_tags.length > 0 then match.tags = $all: selected_post_tags
        
        cloud = Posts.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_post_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
            
        # console.log 'cloud, ', cloud
            
        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
        
