if Meteor.isClient
    Router.route '/services', -> @render 'services'
    Router.route '/service/:doc_id/edit', -> @render 'service_edit'
    Router.route '/service/:doc_id/view', -> @render 'service_view'


    Template.services.onCreated ->
        @autorun -> Meteor.subscribe('type', 'service')

    Template.service_edit.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

    Template.service_view.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)



    Template.services.helpers
        services: ->
            Docs.find {type: 'service'}, sort:service_code:1

    Template.services.events
        'click #add_service': ->
            id = Docs.insert type: 'service'
            Router.go "/service/#{id}/edit"

    Template.service_edit.helpers
        service: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id

    Template.service_view.helpers
        service: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id
