const event = {
    connected: 0,
    click: 1,
}

const commands = {
    reload: 0,
    createElement: 1,
    removeElement: 2,
    replaceElement: 3,
}

const socket = new WebSocket('ws://localhost:4200/ws');

socket.addEventListener('open',  (event) => {
    send(event.connected);
});

socket.addEventListener('message',  (event) => {
    const command = JSON.parse(event.data);
    switch (command.e) {
        case commands.reload:
            return reload();
        case commands.createElement:
            return createElement(command.id, command.i, command.c);
        case commands.removeElement:
            return removeElement(command.id, command.i, command.l);
        case commands.replaceElement:
            return replaceElement(command.id, command.i, command.c);
    }
});

function send(e, extra = {}) {
    socket.send(JSON.stringify({ e, ...extra }));
}

function cl() {
    send(event.click, { id: this.id });
}

function reload() {
    console.log('Reloading...')
    location.reload();
}

function createElement(parentId, i, html) {
    const tmp = document.createElement('div');
    tmp.innerHTML = html;
    const parent = document.getElementById(parentId);
    const afterEl = parent.children[i];
    if (afterEl) {
        for (const child of Array.from(tmp.children)) {
            parent.insertBefore(child, afterEl);
        }
    } else {
        parent.append(...tmp.children);
    }
}

function removeElement(parentId, i, l) {
    const el = document.getElementById(parentId);
    Array.from({ length: l }, (_, x) => i + x).map(i => el.children[i]).forEach(e => e.remove());
}

// TODO: replaceElement
function replaceElement(targetId, html) {
    const el = document.getElementById(targetId);
    const index = Array.from(el.parentElement.children).findIndex(e => e === el);
    document.getElementById(targetId).innerHTML += html;
}
