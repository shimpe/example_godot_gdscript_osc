extends Node2D

var IP_CLIENT
var PORT_CLIENT
var PORT_SERVER = 4242
var IP_SERVER = "127.0.0.1"
var socketUDP = PacketPeerUDP.new()
var observers = Dictionary()
var timer

func register_callback(number_of_arguments, oscaddress, node, functionname):
	observers[oscaddress] = [number_of_arguments, node, functionname]
	
func _ready():
	# configure all sensors
	for x in range(4):
		for y in range(4):
			var linindx = y*4 + x
			var nodename = "Sensor" + str(linindx+1)
			var width = get_tree().root.get_visible_rect().size.x
			var height= get_tree().root.get_visible_rect().size.y
			var cx = ((x*2) + 1.5)*width/9
			var cy = ((y*2) + 1.5)*height/9
			get_node(nodename).set_position(Vector2(cx, cy))
			get_node(nodename).set_scale(Vector2(0.5, 0.5))
			get_node(nodename).listen_to("/" + str(linindx) + "/set/color")
			
	timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 0.1
	timer.connect("timeout", self, "_on_timeout")
	add_child(timer)
	
	# start listening for osc messages
	start_server()
	
func all_zeros(lst):
	if lst == []:
		return true
	for el in lst:
		if el != 0:
			return false
	return true

func _on_timeout():
	if socketUDP.get_available_packet_count() > 0:
		var array_bytes = socketUDP.get_packet()
		#var IP_CLIENT = socketUDP.get_packet_ip()
		#var PORT_CLIENT = socketUDP.get_packet_port()
		var stream = StreamPeerBuffer.new()
		stream.set_data_array(array_bytes)
		stream.set_big_endian(true)
		var address_finished = false
		var type_finished = false
		var address = ""
		var type = ""
		while not address_finished:
			for _i in range(4):
				var addrpart = stream.get_u8()
				if addrpart != 0:
					address += char(addrpart)
				if addrpart == 0:
					address_finished = true
					
		while not type_finished:
			for _i in range(4):
				var c = stream.get_u8()
				if c != 0 and char(c) != ",":
					type += char(c)
				if c == 0:
					type_finished = true
		
		#printt("address: " + address + ".")
		#printt("type: " + type + ".")
		
		var values = []
		for type_id in type:
			if type_id == "i":
				var intval = stream.get_32()
				#printt("parse int: ", intval)
				values.append(intval)
			elif type_id == "f":
				var floatval = stream.get_float()
				values.append(floatval)
			elif type_id == "s":
				var stringval = ""
				var string_finished = false
				while not string_finished:
					for _i in range(4):
						var ch = stream.get_u8()
						if ch != 0:
							stringval += char(ch)
						else:
							string_finished = true
				values.append(stringval)
			elif type_id == "b":
				var data = []
				var count = stream.get_u32()
				var idx = 0
				var blob_finished = false
				while not blob_finished:
					for _i in range(4):
						var ch = stream.get_u8()
						if idx < count:
							data.append(ch)
						idx += 1
						if idx >= count:
							blob_finished = true
				values.append(data)
			else:
				printt("type " + type_id +" not yet supported")

		if observers.has(address):
			var observer = observers[address]
			var number_args = observer[0]
			var nodepath = observer[1]
			var funcname = observer[2]
			if number_args == 1:
				#print(1)
				nodepath.call(funcname, values[0])
			elif number_args == 2:
				#print(2)
				nodepath.call(funcname, values[0], values[1])
			elif number_args == 3:
				#print(3)
				nodepath.call(funcname, values[0], values[1], values[2])
			elif number_args == 4:
				#print(4)
				nodepath.call(funcname, values[0], values[1], values[2], values[3])
			elif number_args == 5:
				#print(5)
				nodepath.call(funcname, values[0], values[1], values[2], values[3], values[4])
			elif number_args == 6:
				#print(6)
				nodepath.call(funcname, values[0], values[1], values[2], values[3], values[4], values[5])
			else:
				printt("Please add support for calls with ", number_args, " arguments in the RootNode script.")
				

func _process(_delta):
	pass
				
func start_server():
	if (socketUDP.listen(PORT_SERVER) != OK):
		printt("Error listening on port: " + str(PORT_SERVER))
	else:
		printt("Listening on port: " + str(PORT_SERVER))

func _exit_tree():
	socketUDP.close()
	
