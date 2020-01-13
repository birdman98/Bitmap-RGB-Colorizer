#pragma once

#ifdef COLORIZER_C_DLL_EXPORTS
#define COLORIZER_C_DLL_API __declspec(dllexport)
#else
#define COLORIZER_C_DLL_API __declspec(dllimport)
#endif

#include <string>


extern "C" COLORIZER_C_DLL_API void processBitmap(unsigned char* bitmap, const int &begin, const int &end, const char &color);