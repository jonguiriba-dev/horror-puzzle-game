extends Node2D

var connections :Array= []	

func _draw():
	
	for connection in connections:
		var curve = Curve2D.new()
		curve.bake_interval = 10
		curve.add_point(connection.source.position)
		curve.add_point(connection.target.position)
			#curve.set_point_in(i,points[i].in_point)
			#curve.set_point_out(i,points[i].out_point)
		
		curve.tessellate()
		var curved_points = curve.get_baked_points()
		draw_polyline(curved_points, Color.WHITE, 3)
