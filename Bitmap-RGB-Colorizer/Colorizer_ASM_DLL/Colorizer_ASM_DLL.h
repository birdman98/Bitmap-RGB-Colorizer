#pragma once

#include "stdafx.h"
#include <string>

__pragma(comment(linker, "/export:processBitmapInAsm"));

extern "C" __declspec(dllexport) unsigned char* __stdcall processBitmapInAsm(unsigned char* bitmap, int height, int width, /*std::string*/char color);

