function hexStringToArrayBuffer(hexString) {
    var pairs = hexString.match(/[\dA-F]{2}/gi);
    var integers = pairs.map(function(s) {
        return parseInt(s, 16);
    });
    var array = new Uint8Array(integers);
    return array.buffer;
}

function des_encrypt(data, key) {
    data = CryptoJS.lib.WordArray.create(data);
    key = CryptoJS.lib.WordArray.create(key);
    let result = CryptoJS.DES.encrypt(data, key, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return hexStringToArrayBuffer(result.ciphertext.toString())
}

function des_decrypt(data, key) {
    data = CryptoJS.lib.WordArray.create(data);
    key = CryptoJS.lib.WordArray.create(key);
    let result = CryptoJS.DES.decrypt({ciphertext: data}, key, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return hexStringToArrayBuffer(result.toString())
}

function tdes_encrypt(data, key) {
    data = CryptoJS.lib.WordArray.create(data);
    key = CryptoJS.lib.WordArray.create(key);
    let result = CryptoJS.TripleDES.encrypt(data, key, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return hexStringToArrayBuffer(result.ciphertext.toString())
}

function tdes_decrypt(data, key) {
    data = CryptoJS.lib.WordArray.create(data);
    key = CryptoJS.lib.WordArray.create(key);
    let result = CryptoJS.TripleDES.decrypt({ciphertext: data}, key, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return hexStringToArrayBuffer(result.toString())
}
