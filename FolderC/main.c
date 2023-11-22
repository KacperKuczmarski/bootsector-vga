
void _start(void){
	// VGA Address
	unsigned short* VGA = (unsigned short*)0xa000;
//	while(1){
//		if(VGA > (0xa000 + 64000)){
//			VGA = (unsigned short*)0xa000; // let's start over again
//		}
//		VGA++;
//		*VGA = 0;
//	}
	// Goto next pixel
	VGA++;
	// set it to black
	*VGA = 0;
	while(1){}	
}

