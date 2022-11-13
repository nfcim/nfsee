class NativeCaller {
  constructor() {
    this.communicator = nfsee || window.nfsee || window.messageHandlers.nfsee || window.native || webkit.messageHandlers.native;
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
  const ret = new Promise((resolve, reject) => {
    pendingPromise = [resolve, reject];
  });

  nativeCaller.postMessage(message, data);
  return ret;
}

const returnDataToPendingPromise = (data) => {
  if (pendingPromise) {
    pendingPromise[0](data);
    pendingPromise = null;
  }
};

const rejectPendingPromise = (e) => {
  if (pendingPromise) {
    pendingPromise[1](e);
    pendingPromise = null;
  }
};

const poll = () => callNativeAndSetPendingPromise('poll');

const pollCallback = returnDataToPendingPromise;

const pollErrorCallback = rejectPendingPromise;

const transceive = (rapdu) => callNativeAndSetPendingPromise('transceive', rapdu);

const transceiveCallback = returnDataToPendingPromise;

const transceiveErrorCallback = rejectPendingPromise;

function report(data) {
  nativeCaller.postMessage('report', data);
}

function error(data) {
  nativeCaller.postMessage('error', data);
}

function log(data) {
  nativeCaller.postMessage('log', data);
}

function finish(data) {
  nativeCaller.postMessage('finish', data);
}
