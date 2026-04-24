let usernamePopup, readerViewPopup, arrow, skipReaderView, playerContainer;

///////////////////////////////////////////
// TERMINAL                             //
///////////////////////////////////////////

let terminalContainer, sections, navButtons, contentFrame;

function navButtonClicked(e, buttonClicked) {
  if (e.ctrlKey) {
		navButtonAuxClicked(e, buttonClicked);
		return;	
  }

	showReaderViewNotification();

	const nextURL = `/${buttonClicked.id.replace('-button', '')}`;

	if (window.location.pathname === nextURL) return;

	const nextState = { additionalInformation: 'Updated via JS ' + nextURL };

	contentFrame.data = nextURL + nextURL + ".html";
	
	window.history.pushState(nextState, "", nextURL);
  
	setActiveNavButton(buttonClicked);
}

function navButtonAuxClicked(e, buttonClicked) {
	const url = `/${buttonClicked.id.replace('-button', '')}`;
	window.open(`${window.location.origin + url + url}.html`, '_blank').focus()
}

window.addEventListener("popstate", (event) => {
	const buttonId = event.target.location.pathname.substring(1) + "-button";
	const buttonClicked = document.getElementById(buttonId);

	setActiveNavButton(buttonClicked);
})

function setActiveNavButton(buttonClicked) {
  navButtons.forEach(btn => { btn.classList.remove('active'); });
  buttonClicked.classList.add('active');
}

function setNavButtonEventListeners() {
	navButtons.forEach(button => {
		button.addEventListener('click', (evt) => navButtonClicked(evt, button));
		button.addEventListener('auxclick', (evt) => navButtonAuxClicked(evt, button));
	})
}

function readerViewNotificationClosed() {
	closeReaderViewNotification();

	let clearedRVNotificationTimes = localStorage.getItem("clearedRVNotificationTimes")
	if (!clearedRVNotificationTimes) {
		localStorage.setItem("clearedRVNotificationTimes", "1");
		return
	}

	clearedRVNotificationTimes = parseInt(clearedRVNotificationTimes) + 1;
	localStorage.setItem("clearedRVNotificationTimes", clearedRVNotificationTimes.toString());

	if (clearedRVNotificationTimes >= 2) {
		skipReaderView.disabled = false;
	}
}

function readerViewNotificationSkipped() {
	localStorage.setItem("skipReaderView", "true");
	closeReaderViewNotification();
}

function closeReaderViewNotification() {
	arrow.style.display = "none";
	readerViewPopup.style.display = "none";
}

function showReaderViewNotification() {
	let skipReaderViewValue = localStorage.getItem("skipReaderView");
	if (skipReaderViewValue && skipReaderViewValue === "true") {
		return;
	}

	readerViewPopup.style.display = "block"
	arrow.style.display = "block";
}

function setReaderViewNotificationEventListeners() {
	const host = document.getElementById('reader-view-shadow-host');

	var closeReaderViewNotificationButtons = host.shadowRoot.querySelectorAll(('.reader-view-notification-close-button'));
	closeReaderViewNotificationButtons.forEach(button => {
		button.addEventListener('click', readerViewNotificationClosed);
	})

	skipReaderView = host.shadowRoot.querySelector(('#skip-reader-view'));
	skipReaderView.addEventListener('click', readerViewNotificationSkipped);
}

function setTerminalBounds(x, y, width, height) {
	terminalContainer.style.left = `${x}px`;
	terminalContainer.style.top = `${y}px`;
	terminalContainer.style.width = `${width}px`;
	terminalContainer.style.maxWidth = `${width}px`;
	terminalContainer.style.height = `${height}px`;
}


function toggleTerminalVisibility(visible) {
	terminalContainer.style.display = visible ? "block" : "none";
	terminalContainer.style.opacity = 0.0;

	if (visible) {
		fadeInTerminal(0.0);
	} 
}

function fadeInTerminal(opacity) {
	if (opacity >= 1.0) return;

  setTimeout(() => {
    opacity += 0.04;
		terminalContainer.style.opacity = opacity;

    fadeInTerminal(opacity);
  }, 10);
};


///////////////////////////////////////////
// JS BRIDGE                             //
///////////////////////////////////////////

let rotatePopup

function showRotateDeviceIcon(show) {
	rotatePopup.style.display = show ? "flex" : "none";
}


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


function getUsername() {
	return localStorage.getItem("username");
}


function setTerminalGUIVisible(lockedOnTerminal) {
	toggleTerminalVisibility(lockedOnTerminal);
}

function checkSetPersonalBest(score) {
	let personalBest = parseInt(localStorage.getItem("personalBest") || "0");
	if (score > personalBest) {
		localStorage.setItem("personalBest", score.toString());
		return true
	}

	return false;
}

function getPersonalBest() {
	return parseInt(localStorage.getItem("personalBest") || "0");
}

function setPlayerVisible(visible) {
	if (!musicStarted) return;
	let position = visible ? "0px" : "-30dvh";
	playerContainer.style.top = position;
}

///////////////////////////////////////////
// QUERIES                               //
///////////////////////////////////////////

let scores = null
let scoresSentToGodot = false;

async function saveScore(score) {
	if (!score) return;

	let username = localStorage.getItem("username")
	if (!username) {
		setLastScore(score);
		usernamePopup.showModal()
		return;
	}
	
	fetch(`${window.location.origin}/api/runs`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, score }),
  })
}

sendTopScoresToGodot = null; // set in godot

function loadRuns() {
	fetch(`${window.location.origin}/api/runs`, {
		method: 'GET'
	})
	.then(response => response.json())
	.then(data => {
		scores = [data.percentiles, data.topRuns]
		if (sendTopScoresToGodot && !scoresSentToGodot) {
			sendTopScoresToGodot(scores); // godot callback reference
			scoresSentToGodot = true;
		}
	})
	.catch(error => console.error(error));
}

///////////////////////////////////////////
// EVENTS                                //
///////////////////////////////////////////

let lastScore = 0;
let usernameTextBox

function setLastScore(score) {
	lastScore = score;
}


function _onSubmitUsername(event) {
	event.preventDefault();
	let username = usernameTextBox.value;
	localStorage.setItem("username", username);
	
	usernamePopup.close();
	console.log(`username set to ${username} in localStorage.`);

	saveScore(lastScore);
}


function _onShowDebugCheckBoxChanged(show) {
	if (this.checked) {
		onShowDebug(true) // godot callback reference
	} else {
		onShowDebug(false) // godot callback reference
	}
}


///////////////////////////////////////////
// STARTUP                               //
///////////////////////////////////////////

let loadingScreen

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

// function onProgress(current, total) {
// 	let date = new Date();
// 	let time = date.toLocaleTimeString();
// 	let header = `[${time}] `;

// 	loadingScreen.innerText += "\n" + header + loadingTexts[textIndex];

// 	textIndex++;
// }

const GODOT_CONFIG = {
	executable: "./build/godot",
	canvasResizePolicy: 2,
	onProgress: function (current, total) {

		if (textIndex >= loadingTexts.length) return;

		let date = new Date();
		let time = date.toLocaleTimeString();
		let header = `[${time}] `;

		loadingScreen.innerText += "\n" + header + loadingTexts[textIndex];

		textIndex++;
	}
}
const GODOT_THREADS_ENABLED = false;
let engine = null;

// copied from YouTube IFrame API docs: https://developers.google.com/youtube/iframe_api_reference
// 2. This code loads the IFrame Player API code asynchronously.
var tag = document.createElement('script');

tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

// 3. This function creates an <iframe> (and YouTube player)
//    after the API code downloads.
var player;
function onYouTubeIframeAPIReady() {
	console.log("YouTube Iframe API ready, creating player.");
	player = new YT.Player('player', {
		height: '480',
		width: '480',
		videoId: 'UQoqB2rh1Ew',
		playerVars: {
			'playsinline': 1
		},
		events: {
			'onReady': onPlayerReady,
			'onStateChange': onPlayerStateChange
		}
	});
}

// 4. The API will call this function when the video player is ready.
function onPlayerReady(event) {
	return;
}

// 5. The API calls this function when the player's state changes.
//    The function indicates that when playing a video (state=1),
//    the player should play for six seconds and then stop.
// var done = false;
function onPlayerStateChange(event) {
	console.log("YouTube Player state changed: " + event.data);
	// if (event.data == YT.PlayerState.PLAYING && !done) {
	// 	setTimeout(stopVideo, 6000);
	// 	done = true;
	// }
}
// function stopVideo() {
// 	player.stopVideo();
// }

var playerVolume = 0;
function setPlayerVolume(volume) {
	console.log("Setting player volume to " + volume);
	playerVolume = volume;
	player.setVolume(playerVolume);
}

function rampUpPlayerVolume() {
	if (playerVolume >= 20) return;
	setPlayerVolume(playerVolume + 1);
	setTimeout(rampUpPlayerVolume, 300);
}

var musicStarted = false;
function playAmbientMusic(evt) {
	setPlayerVolume(0);
	player.playVideo();
	rampUpPlayerVolume();

	setPlayerVisible(true);
}

window.addEventListener('DOMContentLoaded', () => {

	loadSharedElements();

	loadingScreen.innerText = startText;

	loadRuns();

	registerEventListeners();

	engine = new Engine(GODOT_CONFIG)

	setNavButtonEventListeners();

	setReaderViewNotificationEventListeners();

	// onYouTubeIframeAPIReady();
	// playAmbientMusic();

	document.getElementById("canvas").addEventListener("click", (evt) => {
		if (musicStarted) return;

		musicStarted = true;
		playAmbientMusic(evt);
	})

	let pathName = window.location.pathname
	let associatedButton = document.getElementById(pathName.substring(1) + "-button");
	if (!associatedButton) {
		pathName = "/intro"
		associatedButton = document.getElementById(pathName.substring(1) + "-button");
	}
	
	contentFrame.data = pathName + pathName + ".html";
	
	const nextState = { additionalInformation: 'Updated via JS ' + pathName };
	window.history.replaceState(nextState, "", pathName);

	setActiveNavButton(associatedButton);
	
	engine.startGame().then(() => {
		if (!scoresSentToGodot && scores) {
			// query returned before godot was ready, send scores now that godot is ready
			sendTopScoresToGodot(scores); // godot callback reference
			scoresSentToGodot = true;
		}

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


function loadSharedElements() {
	terminalContainer = document.getElementById("terminal-container");
	sections = document.querySelectorAll('.section');
	navButtons = document.querySelectorAll('.nav-button');
	rotatePopup = document.getElementById("rotate-device-popup");
	loadingScreen = document.getElementById("loading");
	usernameTextBox = document.getElementById("username-textbox");
	usernamePopup = document.getElementById("username-popup")
	readerViewPopup = document.getElementById("reader-view-popup");
	contentFrame = document.getElementById("content-frame");
	arrow = document.getElementById("arrow");
	playerContainer = document.getElementById("player-container");
}


function registerEventListeners() {
	// var showDebugCheckBox = document.getElementById("show-debug");
	// showDebugCheckBox.addEventListener('change', _onShowDebugCheckBoxChanged)

	var usernameForm = document.getElementById("username-form");
	usernameForm.addEventListener('submit', _onSubmitUsername);
}

