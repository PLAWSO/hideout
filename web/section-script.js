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
	if (window.top.location.href.includes(".html")) {
		var lnk = document.createElement('link');
		lnk.type='text/css';
		lnk.href='../reader-view-styles.css';
		lnk.rel='stylesheet';
		document.getElementsByTagName('head')[0].appendChild(lnk);
		document.styleSheets[0].disabled = true;
		// document.styleSheets[1].disabled = true;
	}
});

function openInReaderView() {
	window.open(window.location.href, "_blank");
}

