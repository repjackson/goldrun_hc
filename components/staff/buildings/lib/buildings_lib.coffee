@Buildings = new Meteor.Collection 'buildings'

Buildings.helpers
    apartments: -> Apartments.find building_id: @_id
    when: -> moment(@timestamp).fromNow()
    label: ->
        string = ''
        for building_number in @building_numbers
            # string.concat building_number
            console.log building_number
            string.concat ", "
        string.concat @building_street
        console.log string
        string

@Apartments = new Meteor.Collection 'apartments'
@Residents = new Meteor.Collection 'residents'

Apartments.helpers
    building: -> Building.findOne @building_id
    residents: -> Residents.find apartment_id: @_id

