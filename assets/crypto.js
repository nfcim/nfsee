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
    let result = CryptoJS.DES.encrypt(key, data, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return hexStringToArrayBuffer(result.ciphertext.toString())
}
