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

window.addEventListener('DOMContentLoaded', () => {
	var terminal = document.getElementById("terminal");

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
			terminal.innerText += (okayPrevious ? " - OK!\n" : "\n") + (directoryCurrent ? directory : "") + loadingTexts[textIndex].text;

			textIndex++;
		},
	});
	
	engine.startGame().then(() => {
		console.log("Game started successfully");

		terminal.innerText += " - OK!"

		setTimeout(() => {
			terminal.innerText += "\n\nCONNECTION ESTABLISHED.";
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


