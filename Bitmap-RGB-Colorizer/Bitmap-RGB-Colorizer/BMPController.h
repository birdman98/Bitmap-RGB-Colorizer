#pragma once

#include <string>
#include "bmp.h"

class BMPController
{
private:
	BMPFileHeader bmpFileHeader;
	BMPInfoHeader bmpInfoHeader;
	uint32_t makeStrideAligned(const uint32_t &alignStride, uint32_t &rowStride);
	unsigned char* data;
	unsigned char* paddingRow;
	int paddingSize = 0;
	uint32_t rowStride = 0;
	int sizeOfPixelsInArray = 0;

public:
	bool loadBitmap(const std::string &bmpPath);
	bool saveBitmap(const std::string &bmpPath);

	unsigned char* getBitmapPixels();
	void setBitmapPixels(unsigned char* bitmapPixels);

	int getBitmapWidth() const;
	int getBitmapHeight() const;
	int getSizeOfBitmapPixels() const;

	~BMPController();
};