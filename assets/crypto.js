function _hexStringToArrayBuffer(hexString) {
    const pairs = hexString.match(/[\dA-F]{2}/gi);
    const integers = pairs.map(s => parseInt(s, 16));
    return new Uint8Array(integers).buffer;
}

function _tdes2to3(key) {
    const fullKey = new Uint8Array(24);
    fullKey.set(new Uint8Array(key), 0);
    fullKey.set(new Uint8Array(key).slice(0, 8), 16);
    return CryptoJS.lib.WordArray.create(fullKey);
}

function _xor(a, b) {
    const result = new Uint8Array(8);
    for (let i = 0; i < 8; ++i)
        result[i] = a[i] ^ b[i];
    return result;
}

function des_encrypt(data, key) {
    if (data.byteLength % 8 != 0) throw "invalid data length";
    if (key.byteLength != 8) throw "invalid key length";
    data = CryptoJS.lib.WordArray.create(data);
    key = CryptoJS.lib.WordArray.create(key);
    const result = CryptoJS.DES.encrypt(data, key, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return _hexStringToArrayBuffer(result.ciphertext.toString())
}

function des_decrypt(data, key) {
    if (data.byteLength % 8 != 0) throw "invalid data length";
    if (key.byteLength != 8) throw "invalid key length";
    data = CryptoJS.lib.WordArray.create(data);
    key = CryptoJS.lib.WordArray.create(key);
    const result = CryptoJS.DES.decrypt({ciphertext: data}, key, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return _hexStringToArrayBuffer(result.toString())
}

function tdes_encrypt(data, key) {
    if (data.byteLength % 8 != 0) throw "invalid data length";
    if (key.byteLength != 16) throw "invalid key length";
    data = CryptoJS.lib.WordArray.create(data);
    const result = CryptoJS.TripleDES.encrypt(data, _tdes2to3(key), {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return _hexStringToArrayBuffer(result.ciphertext.toString())
}

function tdes_decrypt(data, key) {
    if (data.byteLength % 8 != 0) throw "invalid data length";
    if (key.byteLength != 16) throw "invalid key length";
    data = CryptoJS.lib.WordArray.create(data);
    const result = CryptoJS.TripleDES.decrypt({ciphertext: data}, _tdes2to3(key), {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
    return _hexStringToArrayBuffer(result.toString())
}

function pboc_des_mac(data, key, iv) {
    if (key.byteLength != 8) throw "invalid key length";
    if (iv.byteLength != 8) throw "invalid iv length";
    const paddedSize = data.byteLength + (8 - data.byteLength % 8);
    const paddedData = new Uint8Array(paddedSize);
    paddedData.set(new Uint8Array(data));
    paddedData[data.byteLength] = 0x80;
    for (let i = data.byteLength + 1; i < paddedSize; ++i)
        paddedData[i] = 0x00;
    const result = new Uint8Array(8);
    result.set(new Uint8Array(iv));
    for (let i = 0; i < paddedSize / 8; ++i) {
        result.set(_xor(result, paddedData.slice(i * 8, (i + 1) * 8)));
        result.set(new Uint8Array(des_encrypt(result, key)));
    }
    return result.buffer;
}
