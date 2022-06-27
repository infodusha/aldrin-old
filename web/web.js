import onServerActions from '../on_server_actions.json';
import onClientActions from '../on_client_actions.json';

class Actions {
    constructor() {
        // TODO add checks for the existence of the methods
    }

    getAction(f) {
        return onServerActions.indexOf(f.name);
    }
}

class ExecuteActions extends Actions {
    reload() {
        location.reload();
    }

    createElement(id, index, html) {
        const parent = document.getElementById(id);
        const tmp = document.createElement('div');
        tmp.innerHTML = html;
        const afterEl = parent.children[index];
        if (afterEl) {
            for (const child of Array.from(tmp.children)) {
                parent.insertBefore(child, afterEl);
            }
        } else {
            parent.append(...tmp.children);
        }
    }

    removeElement(id, index, n) {
        const el = document.getElementById(id);
        Array.from({ length: n }).map((_, i) => el.children[index + i]).forEach(e => e.remove());
    }

    replaceElement(id, index, html) {
        const parent = document.getElementById(id);
        const tmp = document.createElement('div');
        tmp.innerHTML = html;
        let i = index;
        for (const child of Array.from(tmp.children)) {
            parent.replaceChild(parent.children[i], child);
            i++;
        }
    }
}

class EmitActions extends Actions {

    constructor() {
        super();
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

const socket = new WebSocket('ws://localhost:4200/ws');
const emitter = new EmitActions();
const executor = new ExecuteActions();

socket.addEventListener('open',  () => {
    emitter.connected();
});

socket.addEventListener('message',  (event) => {
    const [e, ...data] = JSON.parse(event.data);
    executor[onClientActions[e]](...data);
});
