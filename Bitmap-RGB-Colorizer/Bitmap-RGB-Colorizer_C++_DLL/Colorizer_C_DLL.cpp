#include "stdafx.h"
#include "Colorizer_C_DLL.h"

const int BYTES_PER_PIXEL = 3;

void processBitmap(unsigned char* bitmap, const int &begin, const int &end, const char &color) {	
	int pixelSpecifier = 0;
	if(color == 'R') {
		pixelSpecifier = 2;		
	} else if(color == 'G') {
		pixelSpecifier = 1;		
	} else {
		pixelSpecifier = 0;
	}

	for (int i = begin; i < end; ++i) {
		if (i % BYTES_PER_PIXEL != pixelSpecifier) {
			bitmap[i] = 0;
		}
	}
}