#include "pch.h"
#include "BMPController.h"

#include <fstream>
#include <iostream>
#include <iterator>
#include <algorithm>

uint32_t BMPController::makeStrideAligned(const uint32_t &alignStride, uint32_t &rowStride) {
	uint32_t new_stride = rowStride;
	while (new_stride % alignStride != 0) {
		new_stride++;
	}
	return new_stride;		
}

bool BMPController::loadBitmap(const std::string &bmpPath) {
	std::ifstream bitmap(bmpPath, std::ios::binary);

	if(!bitmap.good()) {
		std::cerr << "Failed to open bitmap from path: " + bmpPath + "\n\n";
		return false;
	}

	bitmap.read((char*)&this->bmpFileHeader, sizeof(BMPFileHeader));
	bitmap.read((char*)&this->bmpInfoHeader, sizeof(BMPInfoHeader));

	bitmap.seekg(this->bmpFileHeader.offset_data, bitmap.beg);

	
	this->bmpInfoHeader.size = sizeof(BMPInfoHeader);
	this->bmpFileHeader.offset_data = sizeof(BMPFileHeader) + sizeof(BMPInfoHeader);
	
	this->bmpFileHeader.file_size = this->bmpFileHeader.offset_data;

	this->sizeOfPixelsInArray = this->bmpInfoHeader.width * this->bmpInfoHeader.height * BYTES_PER_PIXEL;
	this->data = new unsigned char[this->sizeOfPixelsInArray];

	if(this->bmpInfoHeader.width % 4 == 0) {
		bitmap.read((char*)this->data, this->sizeOfPixelsInArray * sizeof(char));
		this->bmpFileHeader.file_size += this->sizeOfPixelsInArray * sizeof(char);
	} else {
		this->rowStride = this->bmpInfoHeader.width * (this->bmpInfoHeader.bit_count / 8);
		uint32_t newStride = makeStrideAligned(4, rowStride);
		this->paddingRow = new unsigned char[newStride - this->rowStride];
		this->paddingSize = newStride - this->rowStride;

		for(int i = 0; i < this->bmpInfoHeader.height; ++i) {
			bitmap.read((char*)this->data + this->rowStride * i, rowStride);
			bitmap.read((char*)this->paddingRow, newStride - rowStride);
		}
		this->bmpFileHeader.file_size += sizeof(this->data) + this->bmpInfoHeader.height * sizeof(this->paddingRow);
	}

	bitmap.close();
	return true;
}

bool BMPController::saveBitmap(const std::string &bmpPath) {
	std::ofstream resultBitmap(bmpPath, std::ios::binary);
	if (!resultBitmap.good()) {
		std::cerr << "Failed to save bitmap to file!!" << "\n\n";
		return false;
	}

	if(this->bmpInfoHeader.width % 4 == 0) {
		resultBitmap.write((const char*)&this->bmpFileHeader, sizeof(this->bmpFileHeader));
		resultBitmap.write((const char*)&this->bmpInfoHeader, sizeof(this->bmpInfoHeader));
		resultBitmap.write((const char*)this->data, this->sizeOfPixelsInArray);
	} else {
		resultBitmap.write((const char*)&this->bmpFileHeader, sizeof(this->bmpFileHeader));
		resultBitmap.write((const char*)&this->bmpInfoHeader, sizeof(this->bmpInfoHeader));

		for(int i = 0; i < this->bmpInfoHeader.height; ++i) {
			resultBitmap.write((const char*)this->data + this->rowStride * i, this->rowStride);
			resultBitmap.write((const char*)this->paddingRow, this->paddingSize);
		}
	}

	resultBitmap.close();
	return true;
}

unsigned char* BMPController::getBitmapPixels() {
	unsigned char* bitmapPixels = new unsigned char[this->sizeOfPixelsInArray];
	memcpy(bitmapPixels, this->data, this->sizeOfPixelsInArray);

	return bitmapPixels;
}

void BMPController::setBitmapPixels(unsigned char* bitmapPixels) {
	if(this->data != nullptr) {
		delete[] this->data;		
	}	 
	this->data = new unsigned char[this->sizeOfPixelsInArray];
	memcpy(this->data, bitmapPixels, this->sizeOfPixelsInArray);
}

int BMPController::getBitmapWidth() const {
	return this->bmpInfoHeader.width;
}

int BMPController::getBitmapHeight() const {
	return this->bmpInfoHeader.height;
}

int BMPController::getSizeOfBitmapPixels() const {
	return this->sizeOfPixelsInArray;
}

BMPController::~BMPController() {
	if(this->data != nullptr) {
		delete[] this->data;
	}
	if(this->paddingRow != nullptr) {
		delete[] this->paddingRow;
	}
}