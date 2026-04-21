document.fonts.ready.then(function () {
	document.body.style.opacity = "1";
});

function docReady(fn) {
	if (document.readyState === "complete" || document.readyState === "interactive") {
			setTimeout(fn, 1);
	} else {
			document.addEventListener("DOMContentLoaded", fn);
	}
}    

docReady(function() {
	console.log("doc ready.")
});

function openInReaderView() {
	window.open(window.location.href, "_blank");
}

