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

function hex2buf(hexString) {
  const pairs = hexString.match(/[\dA-F]{2}/gi);
  const integers = pairs.map(s => parseInt(s, 16));
  return new Uint8Array(integers).buffer;
}

function buf2hex(buffer) {
  return Array.prototype.map.call(new Uint8Array(buffer), x => ('00' + x.toString(16)).slice(-2)).join('').toUpperCase();
}

function des_encrypt(data, key) {
  if (data.byteLength % 8 !== 0) throw "invalid data length";
  if (key.byteLength !== 8) throw "invalid key length";
  data = CryptoJS.lib.WordArray.create(data);
  key = CryptoJS.lib.WordArray.create(key);
  const result = CryptoJS.DES.encrypt(data, key, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.NoPadding});
  return hex2buf(result.ciphertext.toString())
}

function des_decrypt(data, key) {
  if (data.byteLength % 8 !== 0) throw "invalid data length";
  if (key.byteLength !== 8) throw "invalid key length";
  data = CryptoJS.lib.WordArray.create(data);
  key = CryptoJS.lib.WordArray.create(key);
  const result = CryptoJS.DES.decrypt({ciphertext: data}, key, {
    mode: CryptoJS.mode.ECB,
    padding: CryptoJS.pad.NoPadding
  });
  return hex2buf(result.toString())
}

function tdes_encrypt(data, key) {
  if (data.byteLength % 8 !== 0) throw "invalid data length";
  if (key.byteLength !== 16) throw "invalid key length";
  data = CryptoJS.lib.WordArray.create(data);
  const result = CryptoJS.TripleDES.encrypt(data, _tdes2to3(key), {
    mode: CryptoJS.mode.ECB,
    padding: CryptoJS.pad.NoPadding
  });
  return hex2buf(result.ciphertext.toString())
}

function tdes_decrypt(data, key) {
  if (data.byteLength % 8 !== 0) throw "invalid data length";
  if (key.byteLength !== 16) throw "invalid key length";
  data = CryptoJS.lib.WordArray.create(data);
  const result = CryptoJS.TripleDES.decrypt({ciphertext: data}, _tdes2to3(key), {
    mode: CryptoJS.mode.ECB,
    padding: CryptoJS.pad.NoPadding
  });
  return hex2buf(result.toString())
}

function pboc_des_mac(data, key, iv) {
  if (key.byteLength !== 8) throw "invalid key length";
  if (iv.byteLength !== 8) throw "invalid iv length";
  const paddedSize = data.byteLength + (8 - data.byteLength % 8);
  const paddedData = new Uint8Array(paddedSize);
  paddedData.set(new Uint8Array(data));
  paddedData[data.byteLength] = 0x80;
  for (let i = data.byteLength + 1; i < paddedSize; ++i)
    paddedData[i] = 0x00;
  const result = new Uint8Array(iv);
  for (let i = 0; i < paddedSize / 8; ++i) {
    result.set(_xor(result, paddedData.slice(i * 8, (i + 1) * 8)));
    result.set(new Uint8Array(des_encrypt(result, key)));
  }
  return result.buffer;
}

function pboc_tdes_mac(data, key, iv) {
  if (key.byteLength !== 16) throw "invalid key length";
  let result = pboc_des_mac(data, new Uint8Array(key).slice(0, 8).buffer, iv);
  result = des_decrypt(result, new Uint8Array(key).slice(8, 16).buffer);
  return des_encrypt(result, new Uint8Array(key).slice(0, 8).buffer);
}

function pboc_key_derive(data, key) {
  if (data.byteLength !== 8) throw "invalid data length";
  if (key.byteLength !== 16) throw "invalid key length";
  const result = new Uint8Array(16);
  result.set(new Uint8Array(tdes_encrypt(data, key)));
  const invert = new Uint8Array(new Uint8Array(data));
  for (let i = 0; i < 8; ++i)
    invert[i] = ~invert[i];
  result.set(new Uint8Array(tdes_encrypt(invert.buffer, key)), 8);
  return result.buffer;
}

function self_test() {
  const compare = (a, b) => {
    a = new Uint8Array(a);
    b = new Uint8Array(b);
    if (a.length !== b.length) return false;
    for (let i = 0; i < a.length; ++i)
      if (a[i] !== b[i]) return false;
    return true;
  };

  // des
  let data = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  let key = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  let expected = new Uint8Array([0xE1, 0xB2, 0x46, 0xE5, 0xA7, 0xC7, 0x4C, 0xBC]).buffer;
  console.log('des_encrypt:', compare(des_encrypt(data, key), expected));
  console.log('des_decrypt:', compare(des_decrypt(expected, key), data));

  // tdes
  data = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  key = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F]).buffer;
  expected = new Uint8Array([0xDF, 0x0B, 0x6C, 0x9C, 0x31, 0xCD, 0x0C, 0xE4]).buffer;
  console.log('tdes_encrypt:', compare(tdes_encrypt(data, key), expected));
  console.log('tdes_decrypt:', compare(tdes_decrypt(expected, key), data));

  // pboc des mac
  data = new Uint8Array([0xAA]).buffer;
  key = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  let iv = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  expected = new Uint8Array([0x79, 0xFD, 0xE3, 0x84, 0x7D, 0xC7, 0x0F, 0x8A]).buffer;
  console.log('pboc_des_mac_1:', compare(pboc_des_mac(data, key, iv), expected));

  data = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  key = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  iv = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  expected = new Uint8Array([0xDE, 0x94, 0x31, 0x88, 0xB0, 0xFA, 0x5B, 0xD4]).buffer;
  console.log('pboc_des_mac_2:', compare(pboc_des_mac(data, key, iv), expected));

  data = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x00]).buffer;
  key = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  iv = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  expected = new Uint8Array([0x82, 0x31, 0x4A, 0x35, 0xEE, 0xAB, 0xE5, 0xE3]).buffer;
  console.log('pboc_des_mac_3:', compare(pboc_des_mac(data, key, iv), expected));

  // pboc 3des mac
  data = new Uint8Array([0xAA]).buffer;
  key = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F]).buffer;
  iv = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  expected = new Uint8Array([0xD7, 0xE9, 0xBD, 0xF4, 0xF1, 0xE3, 0x90, 0xF4]).buffer;
  console.log('pboc_tdes_mac:', compare(pboc_tdes_mac(data, key, iv), expected));

  // derive
  data = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).buffer;
  key = new Uint8Array([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F]).buffer;
  expected = new Uint8Array([0xDF, 0x0B, 0x6C, 0x9C, 0x31, 0xCD, 0x0C, 0xE4,
    0x86, 0xA2, 0x7F, 0x12, 0x6B, 0xB7, 0x61, 0x1D]).buffer;
  console.log('pboc_key_derive:', compare(pboc_key_derive(data, key), expected));
}
