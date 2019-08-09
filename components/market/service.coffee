Router.route '/services', -> @render 'services'
Router.route '/service/:doc_id/view', -> @render 'service_view'
Router.route '/service/:doc_id/edit', -> @render 'service_edit'

if Meteor.isClient
    Template.services.onCreated ->
        @autorun => Meteor.subscribe 'services'
    Template.services.onRendered ->
    Template.services.helpers
        services: ->
            Docs.find
                model:'service'
    Template.services.events
        'click .add_services_item': ->
            new_id = Docs.insert
                model:'service'
            Router.go "/service/#{new_id}/edit"

    Template.service_card.events
        'click .view_service': ->
            Docs.update @_id,
                $inc:views:1
            Router.go "/service/#{_id}/view"


    Template.service_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current.params().doc_id
    Template.service_view.onRendered ->
    Template.service_view.helpers
    Template.services.events
        'click .buy_now': ->
            Docs.insert
                model:'transaction'
                service_id: Router.current.params().doc_id
                started:true
                completed:false
            Router.go "/transaction/#{_id}/view"




    Template.service_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current.params().doc_id
    Template.service_edit.onRendered ->
    Template.service_edit.helpers
        services: ->
            Docs.find
                model:'services'
    Template.services.events
        'click .view_service': ->
            Docs.update @_id,
                $inc:views:1
            Router.go "/service/#{_id}/view"


if Meteor.isServer
    Meteor.publish 'services', ->
        Docs.find
            model:$in:['service','service','rental','food']
