import onServerActions from '../on_server_actions.json';
import onClientActions from '../on_client_actions.json';

class Actions {

    constructor({ isEmitter }) {
        const actions = isEmitter ? onServerActions : onClientActions;
        for (const action of actions) {
            if (this[action] === undefined) {
                throw new Error(`Action ${action} is not implemented`);
            }
        }
    }

    getAction(f) {
        return onServerActions.indexOf(f.name);
    }
}

class ExecuteActions extends Actions {

    constructor() {
        super({ isEmitter: false });
    }

    reload() {
        location.reload();
    }

    createElement(id, index, html) {
        const parent = document.getElementById(id);
        const tmp = document.createElement('div');
        tmp.innerHTML = html;
        const afterEl = parent.childNodes[index];
        if (afterEl) {
            for (const child of Array.from(tmp.childNodes)) {
                parent.insertBefore(child, afterEl);
            }
        } else {
            parent.append(...tmp.childNodes);
        }
    }

    removeElement(id, index, n) {
        const parent = document.getElementById(id);
        Array.from({ length: n }).map((_, i) => parent.childNodes[index + i]).forEach(e => e.remove());
    }

    replaceElement(id, html) {
        const item = document.getElementById(id);
        item.innerHTML = html;
    }
}

class EmitActions extends Actions {

    constructor() {
        super({ isEmitter: true });
        window.cl = function (self) {
            emitter.click(self.id);
        }
    }

    _encode(...args) {
        return JSON.stringify(args);
    }

    connected() {
        const act = this._encode(this.getAction(this.connected));
        socket.send(act);
    }

    click(id) {
        const act = this._encode(this.getAction(this.click), id);
        socket.send(act);
    }
}

const protocol = location.protocol === 'https' ? 'wss' : 'ws';
const socket = new WebSocket(`${protocol}://${location.host}/_ws`);
const emitter = new EmitActions();
const executor = new ExecuteActions();

socket.addEventListener('open',  () => {
    emitter.connected();
});

socket.addEventListener('message',  (event) => {
    const [e, ...data] = JSON.parse(event.data);
    executor[onClientActions[e]](...data);
});
