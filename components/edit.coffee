if Meteor.isClient
    Template.edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_from_child_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_fields_from_child_id', Router.current().params.doc_id

    Template.edit.helpers
        current_doc: ->
            Docs.findOne Router.current().params.doc_id

        fields: ->
            Docs.find
                type:'field'

if Meteor.isServer
    Meteor.publish 'model_from_child_id', (child_id)->
        child = Docs.findOne child_id
        Docs.find
            type:'model'
            slug:child.type


    Meteor.publish 'model_fields_from_child_id', (child_id)->
        child = Docs.findOne child_id
        model = Docs.findOne
            type:'model'
            slug:child.type
        Docs.find
            type:'field'
            parent_id:model._id
