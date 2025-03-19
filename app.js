window.WordCounterModule().then((module) => {
    console.log("WordCounter WebAssembly module loaded.");

    const countWords = (text) => {
	if (!module) {
	    console.error("WordCounter module not loaded.");
	    return;
	}

	let wcInstance = new module.WordCount(text);

	// Create a WordCount instance and call the method
	let wordCount = wcInstance.countWords();

	wcInstance.delete();

	return wordCount;
    };

    const textInput = document.getElementById("text-input");
    const wordCountElement = document.getElementById("count");

    const setCount = () => {
	let text = textInput.value;
	let count = countWords(text);

	wordCountElement.innerText = count;
    };

    // Set initial count
    setCount();

    textInput.addEventListener("input", () => {
	setCount();
    });
});
