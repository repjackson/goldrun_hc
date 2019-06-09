if Meteor.isClient
    Template.unit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.unit_id
        # @autorun => Meteor.subscribe 'unit_units', Router.current().params.unit_code

    Template.unit.helpers
        unit: ->
            Docs.findOne
                model:'unit'
                slug: Router.current().params.unit_code

        units: ->
            Docs.find {
                model:'unit'
            }, sort: unit_number:1
                # unit_slug:Router.current().params.unit_code

    Template.unit.events
        'keyup .unit_number': (e,t)->
            if e.which is 13
                unit_number = parseInt $('.unit_number').val().trim()
                unit_number = parseInt $('.unit_number').val()
                unit_label = $('.unit_label').val().trim()
                unit = Docs.findOne model:'unit'
                console.log unit
                Docs.insert
                    model:'unit'
                    unit_number:unit_number
                    unit_number:unit_number
                    unit_number:unit.unit_number
                    unit_code:unit.slug

if Meteor.isServer
    Meteor.publish 'unit', (unit_code)->
        # console.log 'finding unit', unit_code
        Docs.find
            model:'unit'
            slug:unit_code


    Meteor.publish 'unit_units', (unit_code)->
        # console.log 'finding units', unit_code
        Docs.find
            model:'unit'
            unit_code:unit_code
