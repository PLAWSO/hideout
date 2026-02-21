var directory = "PAYTONL@UNATCO: "

var loadingTexts = [
	{ 
		text: `ssh human@10.69.331.12
		
		The programs included with the [HUMAN] are free software;
		the exact distribution terms for each program are described in the
		individual files in /human/share/doc/*/copyright.

		[HUMAN] comes with ABSOLUTELY NO WARRANTY, to the extent
		permitted by applicable law.
		`,
		directory: true,
		ok: false
	},
	{
		text: `sudo humanctl start optical.services`,
		directory: true,
		ok: false
	},
	{
		text: `Spooling neuronet uplink: carrier stabilized.`,
		directory: false,
		ok: true
	},
	{
		text: `Decrypting cortex headers: entropy within limits.`,
		directory: false,
		ok: true
	},
	{
		text: `Mapping gray-matter topology: nodes responding.`,
		directory: false,
		ok: true
	},
	{
		text: `Injecting holo-UI hooks: tactile layer primed.`,
		directory: false,
		ok: true
	},
	{
		text: `Negotiating limbic permissions: empathy sandboxed.`,
		directory: false,
		ok: true
	},
	{
		text: `Compiling thought-VM: runtime seeded with dreams.`,
		directory: false,
		ok: true
	},
	{
		text: `Establishing ghost-presence: remote admin in mindspace.`,
		directory: false,
		ok: true
	},
]
var textIndex = 0;

let terminalContainer, sections, navButtons;

function navButtonClicked(buttonClicked) {
  sections.forEach(sec => { sec.style.display = 'none'; });
  let targetSection = document.getElementById(buttonClicked.id.replace('-button', ''));
  targetSection.style.display = 'block';
  
  navButtons.forEach(btn => { btn.classList.remove('active'); });
  buttonClicked.classList.add('active');
}

function setTerminalBounds(x, y, width, height) {
	terminalContainer.style.left = `${x}px`;
	terminalContainer.style.top = `${y}px`;
	terminalContainer.style.width = `${width}px`;
	terminalContainer.style.maxWidth = `${width}px`;
	terminalContainer.style.height = `${height}px`;
}

var opacity = 0.0;
function setTerminalVisibility(lockedOnTerminal) {
	console.log(`Setting terminal visibility: ${lockedOnTerminal}`);
	terminalContainer.style.display = lockedOnTerminal ? "block" : "none";

	if (lockedOnTerminal) {
		fadeInTerminal(10, opacity);
	} else {
		opacity = 0.0;
		terminalContainer.style.opacity = opacity;
	}
}


function fadeInTerminal(delay, opacity) {
	if (opacity >= 1.0) return;

  setTimeout(() => {
    opacity += 0.04;
		terminalContainer.style.opacity = opacity;

    fadeInTerminal(delay, opacity);
  }, delay);
};

function getCanvasWidth() {
	return document.getElementById("canvas").clientWidth;
}

function getCanvasHeight() {
	return document.getElementById("canvas").clientHeight;
}

window.addEventListener('DOMContentLoaded', () => {
	var loadingScreen = document.getElementById("loading");
	terminalContainer = document.getElementById("terminal-container");
	sections = document.querySelectorAll('.section');
	navButtons = document.querySelectorAll('.nav-button');

	var showDebugCheckBox = document.getElementById("show-debug");
	showDebugCheckBox.addEventListener('change', function() {
		if (this.checked) {
			onShowDebug(true)
		} else {
			onShowDebug(false)
		}
	})

	const canvas = document.getElementById("canvas");
	var engine = new Engine({
		canvas: { element: canvas },
		executable: "./build/godot",
		canvasResizePolicy: 2,
		onProgress: function (current, total) {
			console.log("Loading progress:", current, "/", total)

			if (textIndex >= loadingTexts.length) return;

			let okayPrevious = textIndex != 0 && loadingTexts[textIndex - 1].ok 
			let directoryCurrent = loadingTexts[textIndex].directory
			loadingScreen.innerText += (okayPrevious ? " - OK!\n" : "\n") + (directoryCurrent ? directory : "") + loadingTexts[textIndex].text;

			textIndex++;
		},
	});
	
	engine.startGame().then(() => {
		console.log("Game started successfully");

		loadingScreen.innerText += " - OK!"

		setTimeout(() => {
			loadingScreen.innerText += "\n\nCONNECTION ESTABLISHED.";
		}, 500)

		setTimeout(() => {
			document.getElementById("loading-container").style.display = "none";
		}, 3000);
	}).catch(error => {
		console.error("Error starting the game:", error);
	});

})

function blurCanvas() {
	document.getElementById("canvas").blur();
}


