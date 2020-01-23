
const CardEnum = {
    BJ: 1 << 0,
    SZ: 1 << 1,
    THU: 1 << 2,
    CU: 1 << 3,
    PBOC1: 1 << 4,
    PBOC2: 1 << 5,
    PBOC3: 1 << 6,
    Wuhan: 1 << 7,
    CQ: 1 << 8,
    ALL: 0xFFFF,
};
const PresetAPDU = [
    [CardEnum.BJ, '00B0840020', '10007510123456780000000000000000000000000000000020030101209912019000'],
    [CardEnum.BJ | CardEnum.Wuhan | CardEnum.CU,
        '00A4000002100100', '9000'],
    [CardEnum.SZ, '00A4000002100100', '6f3284075041592e535a54a5279f0801029f0c200000000000000000fd21000051800000a344c2132017031420270314101000009000'],
    // [CardEnum.ALL, '00B08400020', '6A82'],
    [CardEnum.SZ, '00B095001C', '0000000000000000fd21000051800000a344c21320170314202703149000'],
    [CardEnum.THU | CardEnum.CQ, '00A40000023F00', '9000'],
    [CardEnum.THU, '00B0950021', '0009000401f1000550a3000119022522073100041237007d01f407d01e001401019000'],
    [CardEnum.THU, '00B0960026', 'd0c0d1eecf4800000000000000000000000000003030303030303081323031373031303033389000'],
    [CardEnum.THU, '00A4040009A0000000038698070100', '6f328409a00000000386980701a5259f0801019f0c1e62640022333300010301000000000000100011aa201301012015123155669000'],

    [CardEnum.CU, '00A4040009A0000000038698070100', '6F2E8409A00000000386980701A5219F0C1E0000000100000000010100010102030405060708201701012027123100009000'],
    [CardEnum.CU, '00B095001E', '0000000100000000010100010102030405060708201701012027123100009000'],

    [CardEnum.CQ, '00A4040009A0000000038698070100', '6F348409A00000000386980701A5279F0801999F0C2000014000201412032099123100000000000000000000000000000000000000009000'],
    [CardEnum.CQ, '00B095001E', '0001400020141203209912310000000000000000000000000000000000009000'],
    [CardEnum.CQ, '00B0850000', '847540000000FFFF010040004000000212668612201405120002C0A80A181920141203000000000000000000000000009000'],
    [CardEnum.THU, '805C000104', '8000164e9000'],
    [CardEnum.ALL ^ CardEnum.THU, '805C000204', '8000164e9000'],
];
let MockCard = CardEnum.THU;

function poll() {
    return Promise.resolve(JSON.stringify({
        "type": "iso7816",
        "id": "deadbeef",
        "standard": MockCard == CardEnum.THU ? "ISO 14443-4 (Type B)" : "ISO 14443-4 (Type A)",
        "atqa": '',
        "sak": '',
        "historicalBytes": '',
        "protocolInfo": '',
        "applicationData": '',
        "hiLayerResponse": '',
        "manufacturer": '',
        "systemCode": '',
        "dsfId": ''
    }));
}

function transceive(rapdu) {
    console.log('>', rapdu);
    for (const item of PresetAPDU) {
        if (item[0] & MockCard) {
            if (rapdu == item[1]) {
                console.log('<', item[2]);
                return Promise.resolve(item[2]);
            }
        }
    }
    // console.log("file not found");
    console.log('<', '6A82');
    return Promise.resolve('6A82');
}

function report(data) {
    console.log('report', data);
}

function log(data) {
    console.log(data);
}
