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

let pendingPromise = null;

const callNativeAndSetPendingPromise = (message, data) => {
  const ret = new Promise((resolve) => {
    pendingPromise = resolve;
  });

  nativeCaller.postMessage(message, data);
  return ret;
}

const returnDataToPendingPromise = (data) => {
  if (pendingPromise) {
    pendingPromise(data);
    pendingPromise = null;
  }
};

const poll = () => callNativeAndSetPendingPromise('poll');

const pollCallback = returnDataToPendingPromise;

const transceive = (rapdu) => callNativeAndSetPendingPromise('transceive', rapdu);

const transceiveCallback = returnDataToPendingPromise;

function report(data) {
  nativeCaller.postMessage('report', data);
}

function log(data) {
  nativeCaller.postMessage('log', data);
}
