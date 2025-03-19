(() => {
    var script = document.createElement("script");
    script.src = "./bin/web/debug/word_count.js"; // Path to the generated JS glue file
    script.onload = () => {
	WordCounterModule().then((module) => {
	    window.WordCounter = module;
	    console.log("WordCounter WebAssembly module loaded.");
	});
    };
    document.head.appendChild(script);
})();
