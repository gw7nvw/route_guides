# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])"
Place_type.create(name: "Hut", description: "Back country huti open for public use", color: "blue", graphicName: "circle", pointRadius: 4, url: nil)
Place_type.create(name: "Campsite", description: "Official campsite", color: "cyan", graphicName: "triangle", pointRadius: 4, url: nil)
Place_type.create(name: "Camp-spot", description: "A viable informal camp spot", color: "green", graphicName: "triangle", pointRadius: 3, url: nil)
Place_type.create(name: "Summit", description: "A peak", color: "orange", graphicName: "star", pointRadius: 3, url: nil)
Place_type.create(name: "Pass", description: "A trampable pass, col or saddle", color: "yellow", graphicName: "star", pointRadius: 3, url: nil)
Place_type.create(name: "Locality", description: "A town, station, or other inhabited locality", color: "red", graphicName: "square", pointRadius: 3, url: nil)
Place_type.create(name: "Roadend", description: "The point a track leaves a vehicular road", color: "red", graphicName: "square", pointRadius: 3, url: nil)
Place_type.create(name: "Other", description: "Other location forming the start / end of a route", color: "pink", graphicName: "square", pointRadius: 3, url: nil)


#   Mayor.create(name: 'Emanuel', city: cities.first)
