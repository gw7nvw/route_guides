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


Routetype.create(name: "Road", description: "Formed road, 4WD track, etc",difficulty: 1)
Routetype.create(name: "Surfaced walkway", description: "Gravelled / board-walked walking track for all abilities",difficulty: 2)
Routetype.create(name: "Benched track", description: "Benched, maintained, marked tramping track or pack-track",difficulty: 3)
Routetype.create(name: "Tramping track", description: "Cut, marked tramping track: natural, rough ground surface",difficulty: 4)
Routetype.create(name: "Unmaintained track", description: "Former track, overgrown - markers / ground trail still followable",difficulty: 6)
Routetype.create(name: "Marked route", description: "Uncut route, with markers normally within sight",difficulty: 6)
Routetype.create(name: "Unmarked route, clear", description: "Unmarked route, follows obvious geography (river, spur, trail, etc)", difficulty: 8)
Routetype.create(name: "Unmarked route, hard", description: "Unmarked route, no clear geographic features to follow", difficulty: 10)

Gradient.create(name: "Flat", description: "Flat", difficulty: 1)
Gradient.create(name: "Gentle", description: "Gentle slopes", difficulty: 2)
Gradient.create(name: "Moderate", description: "Occasional moderate climbs", difficulty: 4)
Gradient.create(name: "Moderate-hard", description: "Continuous moderate climbs", difficulty: 6)
Gradient.create(name: "Steep", description: "Steep climbs of >1000m", difficulty: 10)

# 
Terrain.create(name: "Easy", description: "Grass / prepared surface", difficulty: 1)
Terrain.create(name: "Easy-moderate", description: "Tussock / river-gravel / open bush / cut track", difficulty: 3)
Terrain.create(name: "Moderate", description: "Low scrub in open or bush / river rocks", difficulty: 5)
Terrain.create(name: "Moderate-hard", description: "Tall, walkable scrub / large rocks, occasional waterfalls or gorges in rivers", difficulty: 7)
Terrain.create(name: "Hard", description: "Thick scrub-bash / continuous river boulders, waterfalls, or gorges", difficulty: 10)
#
#
Alpine.create(name: "None", description: "No alpine skills required", difficulty: 1)
Alpine.create(name: "Alpine weather", description: "Tramp on open tops, exposed to alpine weather", difficulty: 2)
Alpine.create(name: "Occasional scrambles", description: "Tramp with some scrambles and exposure to falls", difficulty: 3)
Alpine.create(name: "Prolonged scrambles", description: "Scramble, frequently on exposed ridges, spurs, faces", difficulty: 4)
Alpine.create(name: "Snow / ice", description: "Scramble with snow/ice sections, ice axe & crampons required",  difficulty: 7)
Alpine.create(name: "Mountaineering", description: "Mountaineering route - technical equipment & skills required", difficulty: 10)
#
River.create(name: "None", description: "No unbridged river crossings", difficulty: 1)
River.create(name: "Streams", description: "Small streams, danger only in extreme weather", difficulty: 2)
River.create(name: "Occasional rivers", description: "Occasional rivers - impassible after heavy rain", difficulty: 5)
River.create(name: "Prolonged rivers", description: "Frequent river travel - impassible after rain, risk of getting trapped", difficulty: 7)
River.create(name: "Extreme rivers", description: "Major rivers - likely to be impassible in all but ideal conditions", difficulty: 10)
#
Securityquestion.create(question:"hooves on a horse", answer: 4)
Securityquestion.create(question:"toes on a man's foot", answer: 5)
Securityquestion.create(question:"fingers on two hands", answer: 10)
Securityquestion.create(question:"wheels on a bicycle", answer: 2)
Securityquestion.create(question:"millimeters in a centimeter", answer: 10)
Securityquestion.create(question:"inches in a foot", answer: 12)
Securityquestion.create(question:"feet in a yard", answer: 3)
Securityquestion.create(question:"letters in the English alphabet", answer: 26)
Securityquestion.create(question:"pins on an NZ plug", answer: 3)
Securityquestion.create(question:"minutes in a quarter hour", answer: 15)
Securityquestion.create(question:"ears on a dog", answer: 2)
Securityquestion.create(question:"wheels on a tricycle", answer: 3)
Securityquestion.create(question:"points for a try (union)", answer: 5)
Securityquestion.create(question:"points for a drop goal (union)", answer: 3)
Securityquestion.create(question:"wheels on a quad-bike", answer: 4)
Securityquestion.create(question:"suits in a pack of cards", answer: 4)
Securityquestion.create(question:"sides on a pentagon", answer: 5)
Securityquestion.create(question:"sides on a hexagon", answer: 6)
Securityquestion.create(question:"thumbs on severn hands", answer: 7)
Securityquestion.create(question:"legs on three cats", answer: 12)
Securityquestion.create(question:"ears on four dogs", answer: 8)

Securityoperator.create(operator:" and I add ", sign: 1)
Securityoperator.create(operator:" and I get another ", sign: 1)
Securityoperator.create(operator:" and I find ", sign: 1)
Securityoperator.create(operator:" and I subtract ", sign: -1)
Securityoperator.create(operator:" and I take away ", sign: -1)
Securityoperator.create(operator:" and I lose ", sign: -1)
Securityoperator.create(operator:" and someone steals ", sign: -1)
Securityoperator.create(operator:" and someone gives me ", sign: 1)

###   Mayor.create(name: 'Emanuel', city: cities.first)
