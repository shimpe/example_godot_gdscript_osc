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