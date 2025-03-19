#include "word_count.hpp"

#ifndef EMSCRIPTEN

#include <iostream>
#include <fstream>

int main(int argc, char** argv) {

    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <file>" << std::endl;
        return 1;
    }

    char* file_name = argv[1];

    std::string content;
    std::ifstream file(file_name);
    if (file.is_open()) {
        content = std::string((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        file.close();
    } else {
	std::cerr << "Error opening file: " << file_name << std::endl;
        return 1;
    }

    WordCount word_count(content);
    int word_count_result = word_count.countWords();

    std::cout << word_count_result << std::endl;

    return 0;
}

#endif // EMSCRIPTEN
