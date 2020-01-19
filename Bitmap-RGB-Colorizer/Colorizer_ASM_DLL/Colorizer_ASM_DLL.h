#pragma once

#include "stdafx.h"
#include <string>

__pragma(comment(linker, "/export:processBitmapInAsm"));

extern "C" __declspec(dllexport) void __stdcall processBitmapInAsm(unsigned char* bitmap, int begin, int end, char pixelSpecifier);

