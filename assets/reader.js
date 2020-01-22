class NativeCaller {
  constructor() {
    this.communicator = window.native || webkit.messageHandlers.native;
  }

  postMessage(action, data) {
    const jsonString = JSON.stringify({
      action: action,
      data: data || {}
    });

    this.communicator.postMessage(jsonString);
  }
}

const nativeCaller = new NativeCaller();

let pending = null;

function pollCallback(data) {
  if (pending) pending(data);
}

function poll() {
  const ret = new Promise((resolve) => {
    pending = resolve;
  });

  nativeCaller.postMessage('poll');
  return ret;
}

function transceiveCallback(data) {
  if (pending) pending(data);
}

function transceive(rapdu) {
  const ret = new Promise((resolve) => {
    pending = resolve;
  });

  nativeCaller.postMessage('transceive', rapdu);
  return ret;
}

function report(data) {
  nativeCaller.postMessage('report', data);
}

function log(data) {
  nativeCaller.postMessage('log', data);
}
