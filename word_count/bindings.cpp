#include <emscripten/bind.h>
#include "word_count.hpp"

using namespace emscripten;

EMSCRIPTEN_BINDINGS(WordCounterModule) {
    class_<WordCount>("WordCount")
        .constructor<std::string>()
        .function("countWords", &WordCount::countWords);
}
