var startText = `
PAYTONL@UNATCO: ssh human@10.69.331.12
		
The programs included with the [HUMAN] are free software;
the exact distribution terms for each program are described in the
individual files in /human/share/doc/*/copyright.

[HUMAN] comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

sudo humanctlstart optical.services
`
var loadingTexts = [
`NET_REQUEST: Searching for endpoint`,
`NET_REQUEST: Found endpoint at 10.69.331.12:1337`,
`NET_REQUEST: Sending authentication packet`,
`NET_REQUEST: Authentication successful`,
`NET_REQUEST: Negotiating connection`,
]
var textIndex = 0;

let terminalContainer, sections, navButtons, rotatePopup;

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

function showRotateDeviceIcon(show) {
	rotatePopup.style.display = show ? "flex" : "none";
}

var opacity = 0.0;
function setTerminalGUIVisible(lockedOnTerminal) {
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

function setWatchedIntro() {
	localStorage.setItem("watchedIntro", "true");
	console.log("watchedIntro set to true in localStorage.");
}

function getWatchedIntro() {
	return localStorage.getItem("watchedIntro") === "true";
}

let lastScore = 0;
async function saveScore(score) {
	let username = localStorage.getItem("username")
	if (!username) {
		lastScore = score;
		document.getElementById("username-popup").showModal()
		return;
	}
	if (!score) return;
	
	query(`${window.location.origin}/api/runs?type=save&username=${username}&score=${score}`);
}

function setUsername(event) {
	event.preventDefault();
	let username = document.getElementById("username-textbox").value;
	localStorage.setItem("username", username);
	document.getElementById("username-popup").close();
	console.log(`username set to ${username} in localStorage.`);
	saveScore(lastScore);
}

async function query(url) {
  try {
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`Response status: ${response.status}`);
    }

    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.error('Fetch error:', error);
  }
}



window.addEventListener('DOMContentLoaded', () => {
	var loadingScreen = document.getElementById("loading");
	loadingScreen.innerText = startText;

	terminalContainer = document.getElementById("terminal-container");
	sections = document.querySelectorAll('.section');
	navButtons = document.querySelectorAll('.nav-button');
	rotatePopup = document.getElementById("rotate-device-popup");

	var showDebugCheckBox = document.getElementById("show-debug");
	showDebugCheckBox.addEventListener('change', function() {
		if (this.checked) {
			onShowDebug(true)
		} else {
			onShowDebug(false)
		}
	})

	var usernameForm = document.getElementById("username-form");
	usernameForm.addEventListener('submit', setUsername);

	var loadingLog = "Loading."
	const canvas = document.getElementById("canvas");
	var engine = new Engine({
		canvas: { element: canvas },
		executable: "./build/godot",
		canvasResizePolicy: 2,
		onProgress: function (current, total) {

			console.log(loadingLog)
			loadingLog += "."

			if (textIndex >= loadingTexts.length) return;

			let date = new Date();
			let time = date.toLocaleTimeString();
			let header = `[${time}] `;

			loadingScreen.innerText += "\n" + header + loadingTexts[textIndex];

			textIndex++;
		},
	});
	
	engine.startGame().then(() => {
		setTimeout(() => {
			loadingScreen.innerText += "\n\nCONNECTION ESTABLISHED.";
		}, 500)

		setTimeout(() => {
			document.getElementById("loading-container").style.display = "none";
		}, 3000);
	}).catch(error => {
		console.error("Failed to start Godot:", error);
	});

})

