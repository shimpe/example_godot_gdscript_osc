extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func listen_to(color_msg):
	get_tree().get_root().get_node("Node2D").register_callback(3, color_msg, get_node("."), "recv_ocv")
	
func linlin(value, inMin, inMax, outMin, outMax):
	var output = ((outMin + outMax) + (outMax - outMin) * (
					(2 * value - (inMin + inMax)) / float(inMax - inMin))) / 2.0
	return output

func recv_ocv(minval, maxval, val):
	var a = 1;
	var r = clamp(linlin(val, minval, maxval, 0.0, 1.0), 0, 1)
	set_modulate(Color(r,0,0,a))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
