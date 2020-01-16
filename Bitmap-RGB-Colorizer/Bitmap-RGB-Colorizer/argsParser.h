#pragma once

#include <string>

class Args {

public:
	static bool parseArgs(int argc, char** argv);
	static void printHelp();

	static char colorizing;
	static std::string inputFilePath;
	static std::string outputFilePathForAsm;
	static std::string outputFilePathForC;
	static int threadsNumber;
	static bool assembly;
	static bool cPlusPlus;
};