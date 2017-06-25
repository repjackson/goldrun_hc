@Buildings = new Meteor.Collection 'buildings'

Buildings.helpers
    apartments: -> Apartments.find building_id: @_id
    when: -> moment(@timestamp).fromNow()

@Apartments = new Meteor.Collection 'apartments'
@Residents = new Meteor.Collection 'residents'

Apartments.helpers
    building: -> Building.findOne @building_id
    residents: -> Residents.find apartment_id: @_id

