#include "word_count.hpp"

#include <sstream>

WordCount::WordCount(const std::string& content)
    : content(content)
{
}

WordCount::~WordCount()
{
}

int WordCount::countWords() const
{
    std::istringstream iss(content);
    int count = 0;
    std::string word;

    while (iss >> word) {
        ++count;
    }

    return count;
}
