extern "C" void _start(){
	// VGA Address
	unsigned long* vga = (unsigned long*)0xa0000;
	unsigned char color = 10;
	while(1){
		if(vga > (unsigned long*)0xafa00){
			vga = (unsigned long*)0xa0000;
			color++;
		}
		*vga = color;
		
		// vga++; move only by one - imposible in C
		asm("inc %0;"
		: "=r" (vga));
	}
	return;
}

