# example_godot_gdscript_osc
simple project showing how a godot 3 game can react to osc messages in gdscript (no gdnative required)

for some background information, please refer to the blog topics at
* part I: https://technogems.blogspot.com/2020/02/driving-godot-game-engine-with-osc.html
* part II: https://technogems.blogspot.com/2021/11/driving-godot-game-engine-with-osc.html

The project defines a grid of 16 "sensors".

Each sensor has a script attached to it to that implements modulation of the sensor color. It expects 3 arguments: a min value, a max value and a current value. The color of the sensor will adapt to the "current value" proportional to where it lies between the min value and the max value. E.g. if you send (0, 100, 49) the sensor will light up for 49%, since 49 lies at 49% between 0 and 100. When the main scene is instantiated, each sensor is added to a list of "observers", meaning that they will be contacted when a relevant OSC message is received.

The root node has a script attached that receives and parses OSC messages, and distributes it to its list of observers who can then react to it.
It does so 10 times per second (but of course this is entirely up to you to define) by means of a timer.

To test that it works, you can use any application that can send OSC messages. E.g. I used supercollider to make the sensors light up like some Christmas tree with the following code:

```
(
b = NetAddr.new("127.0.0.1", 4242); // create the NetAddr
fork {
	1000.do {
		|idx|
		b.sendMsg("/"++15.rrand(0)++"/set/color",0,100,100.rrand(0));
		0.1.wait;
	}
};
)
```

![alt text](https://github.com/shimpe/example_godot_gdscript_osc/blob/main/test.gif?raw=true)
