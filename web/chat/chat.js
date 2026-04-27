
async function saveChat(username, url, message) {
	return fetch(`${window.location.origin}/api/chats`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, url, message }),
  })
}

function _onSubmitChat(event) {
	let username = event.target[0].value;
	let url = event.target[1].value;
	let message = event.target[2].value;
	event.preventDefault();

	if (!username || !message) return;

	chatForm.reset();

	saveChat(username, url, message).then(response => response.json()).then((chats) => {
		console.log(chats)
		currentPage = 0;
		fillChatContainer(chats);
	});
}

let currentPage = 0;
function moveToNextPage() {
	currentPage++;
	getChats().then(chats => fillChatContainer(chats));
}

function moveToPreviousPage() {
	if (currentPage == 0) return;
	currentPage--;
	getChats().then(chats => fillChatContainer(chats));
}

function getChats() {
	return fetch(`${window.location.origin}/api/chats?page=${currentPage}`)
		.then(response => response.json())
}

function fillChatContainer(chats) {
	chatsContainer.replaceChildren();
	chats.forEach(chat => {
		let chatElement = document.createElement("div");
		chatElement.innerText = `[${chat.enteredOn}]${chat.username}@${chat.url}: ${chat.message}`;
		chatsContainer.appendChild(chatElement);
	});
}

let chatContainer, chatForm;
window.addEventListener('DOMContentLoaded', () => {
	chatsContainer = document.getElementById("chats-container");
	getChats().then(chats => fillChatContainer(chats));

	chatForm = document.getElementById("chat-form");
})