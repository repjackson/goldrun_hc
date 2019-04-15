@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'

# Meteor.users.helpers
#     name: ->
#         if @profile.first_name and @profile.last_name
#             "#{@profile.first_name}  #{@profile.last_name}"



Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    # doc.points = 0
    # doc.downvoters = []
    # doc.tags.push Meteor.user().profile.current_herd
    # doc.upvoters = []
    return

if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"




if Meteor.isServer
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.cloudinary_key
        api_secret: Meteor.settings.cloudinary_secret




# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true


Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()


Meteor.methods
    add: (tags=[])->
        id = Docs.insert
            tags: tags
        # Meteor.call 'generate_person_cloud', Meteor.userId()
        return id

    add_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            new_facet_ob = {
                key:filter
                filters:[]
                res:[]
            }
            Docs.update { _id:delta_id },
                $addToSet: facets: new_facet_ob
        Docs.update { _id:delta_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter

        Meteor.call 'fum', delta_id, (err,res)->


    remove_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            Docs.update { _id:delta_id },
                $pull:facets: {key:filter}
        Docs.update { _id:delta_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'fum', delta_id, (err,res)->


if Meteor.isClient
    Template.docs.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array())

    Template.docs.helpers
        docs: ->
            Docs.find { },
                sort:
                    tag_count: 1
                limit: 1

        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'

        selected_tags: -> selected_tags.array()


    Template.view.helpers
        is_author: -> Meteor.userId() and @author_id is Meteor.userId()

        tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else 'basic'

        when: -> moment(@timestamp).fromNow()

    Template.view.events
        'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())

        'click .edit': -> Router.go("/edit/#{@_id}")

    Template.docs.events
        'click #add': ->
            Meteor.call 'add', (err,id)->
                Router.go "/edit/#{id}"

        'keyup #quick_add': (e,t)->
            e.preventDefault
            tag = $('#quick_add').val().toLowerCase()
            if e.which is 13
                if tag.length > 0
                    split_tags = tag.match(/\S+/g)
                    $('#quick_add').val('')
                    Meteor.call 'add', split_tags
                    selected_tags.clear()
                    for tag in split_tags
                        selected_tags.push tag



if Meteor.isServer
    Docs.allow
        insert: (userId, doc) -> doc.author_id is userId
        update: (userId, doc) -> doc.author_id is userId or 'admin' in Meteor.user().roles
        remove: (userId, doc) -> doc.author_id is userId or 'admin' in Meteor.user().roles

    Meteor.publish 'docs', (selected_tags, filter)->

        # user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}
        # selected_tags.push current_herd
        # match.tags = $all: selected_tags
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if filter then match.model = filter

        Docs.find match
            # limit: 20


    Meteor.publish 'doc', (id)->
        Docs.find id
