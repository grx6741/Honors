#pragma once

#include <string>

class WordCount {
public:
    WordCount(const std::string& content);
    ~WordCount();

    int countWords() const; // return number of words

private:
    std::string content;
};
