#include "stdafx.h"
#include "Colorizer_C_DLL.h"
#include "../Bitmap-RGB-Colorizer/bmp.h"

void processBitmap(unsigned char* bitmap, const int &height, const int &width, const std::string &color) {
	int pixelSpecifier1 = 0;
	int pixelSpecifier2 = 0;
	if(color == "R") {
		pixelSpecifier1 = 0;
		pixelSpecifier2 = 1;		
	} else if(color == "G") {
		pixelSpecifier1 = 0;
		pixelSpecifier2 = 2;		
	} else {
		pixelSpecifier1 = 1;
		pixelSpecifier2 = 2;
	}

	for (int i = 0; i < height * width * BITS_PER_PIXEL; ++i) {
		if (i % BITS_PER_PIXEL == pixelSpecifier1 || i % BITS_PER_PIXEL == pixelSpecifier2) {
			bitmap[i] = 0;
		}
	}
}
