#include "pch.h"
#include <iostream>
#include "BMPController.h"
#include "Colorizer_C_DLL.h"
#include "Colorizer_ASM_DLL.h"
#include <chrono>
#include "argsParser.h"
#include <thread>

int main(int argc, char** argv) {
	if (!Args::parseArgs(argc, argv)) {
		return false;
	}

	if(Args::threadsNumber == 0) {
		Args::threadsNumber = std::thread::hardware_concurrency();
		std::cout << "\n\nNumber of threads was not specified or was not specified properly,\noptimal number of threads for your CPU will be used: " 
			<< Args::threadsNumber << " threads.\n\n";
	}
	
	BMPController bmpController;
	if (!bmpController.loadBitmap(Args::inputFilePath)) {
		std::cout << "Bitmap has not been loaded, program will be finished.\n";
		return false;
	}

	unsigned char* bitmapPixelsForC = nullptr;
	unsigned char* bitmapPixelsForAsm = nullptr;
	if(Args::cPlusPlus) {
		bitmapPixelsForC = bmpController.getBitmapPixels();		
	}
	if(Args::assembly) {
		bitmapPixelsForAsm = bmpController.getBitmapPixels();		
	}

	if (Args::assembly) {
		std::thread* threadsForAsm = new std::thread[Args::threadsNumber];
		int begin = 0;
		int end = 0;
		char pixelSpecifier = 0;

		for (int i = 0; i < Args::threadsNumber; ++i) {
			begin = i * (bmpController.getSizeOfBitmapPixels() / Args::threadsNumber);
			end = (i + 1) * (bmpController.getSizeOfBitmapPixels() / Args::threadsNumber);

			pixelSpecifier = Args::colorizing + (begin % 3);
			threadsForAsm[i] = std::thread(processBitmapInAsm, bitmapPixelsForAsm, begin, end, pixelSpecifier);
		}

		auto start = std::chrono::high_resolution_clock::now();
		for (int i = 0; i < Args::threadsNumber; ++i) {
			threadsForAsm[i].join();
		}
		auto finish = std::chrono::high_resolution_clock::now();

		std::chrono::duration<double> elapsed = finish - start;
		double seconds = elapsed.count();
		std::cout << "Elapsed time for assembly algorithm in DLL with " << Args::threadsNumber << " threads: " << seconds << " seconds\n";

		bmpController.setBitmapPixels(bitmapPixelsForAsm);
		if (bmpController.saveBitmap(Args::outputFilePathForAsm)) {
			std::cout << "Output file from Assembly algorithm saved in: " << Args::outputFilePathForAsm << "\n\n";
		}
		else {
			std::cerr << "Failed to save colorized bitmap to file!\n\n";
		}

		delete[] threadsForAsm; //may throws exception in RELEASE mode, caused by ntdll.dll 
	}
	
	if(Args::cPlusPlus) {
		std::thread* threadsForC = new std::thread[Args::threadsNumber];
		int begin = 0;
		int end = 0;

		for(int i = 0; i < Args::threadsNumber; ++i) {
			begin = i * (bmpController.getSizeOfBitmapPixels() / Args::threadsNumber);
			end = (i + 1) * (bmpController.getSizeOfBitmapPixels() / Args::threadsNumber);
			
			threadsForC[i] = std::thread(processBitmap, bitmapPixelsForC, begin, end, Args::colorizing);
		}

		auto start = std::chrono::high_resolution_clock::now();
		for(int i = 0; i <Args::threadsNumber; ++i) {
			threadsForC[i].join();
		}
		auto finish = std::chrono::high_resolution_clock::now();

		std::chrono::duration<double> elapsed = finish - start;
		double seconds = elapsed.count();
		std::cout << "Elapsed time for C++ algorithm in DLL with " << Args::threadsNumber << " threads: " << seconds << " seconds\n";
		
		bmpController.setBitmapPixels(bitmapPixelsForC);
		if(bmpController.saveBitmap(Args::outputFilePathForC)) {
			std::cout << "Output bitmap colorized by C++ algorithm saved in: " << Args::outputFilePathForC << "\n\n";
		} else {
			std::cerr << "Failed to save colorized by C++ algorithm bitmap to file!\n\n";
		}

		delete[] threadsForC;
	}

	delete[] bitmapPixelsForC;
	delete[] bitmapPixelsForAsm;
}
