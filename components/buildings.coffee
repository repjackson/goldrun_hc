if Meteor.isClient
    Template.buildings.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'building'
    Template.building.onCreated ->
        @autorun => Meteor.subscribe 'building', Router.current().params.building_code
        @autorun => Meteor.subscribe 'building_units', Router.current().params.building_code

    Template.buildings.onRendered ->

    Template.buildings.helpers
        buildings: ->
            Docs.find
                model:'building'



    Template.building.helpers
        building: ->
            Docs.findOne
                model:'building'
                building_code: Router.current().params.building_code

        units: ->
            Docs.find
                building_slug:Router.current().params.building_code

    Template.checkin_button.events


if Meteor.isServer
    Meteor.publish 'building', (building_code)->
        # console.log building_code
        Docs.find
            model:'building'
            building_code:building_code


    Meteor.publish 'building_units', (building_code)->
        # console.log building_code
        Docs.find
            model:'unit'
            building_slug:building_code
