const GBKDecoder = new TextDecoder('gbk');
let Hex2TypeArray = (hexStr) => {
    return new Uint8Array(hexStr.match(/[\da-f]{2}/gi).map(function (h) {
        return parseInt(h, 16)
    }));
};
let ParseGBKText = (hexStr) => {
    return GBKDecoder.decode(Hex2TypeArray(hexStr));
};
let ReadBalance = async () => {
    const rapdu = await transceive('805C000204');
    if (!rapdu.endsWith('9000'))
        return 'N/A';
    return parseInt(rapdu.slice(0, 8), 16) / 100 + '元';
};
let BasicInfoFile = async (fci) => {
    let r = await transceive('00B095001E');
    if (!r.endsWith('9000'))
        return '';
    return r.slice(0, -4);
};
let ReadTransBeijing = async (content04) => {
    let r = await transceive('00A40000021001');
    if (!r.endsWith('9000'))
        return {};
    const number = content04.slice(0, 16);
    const issue_date = content04.slice(48, 56);
    const expiry_date = content04.slice(56, 64);
    const balance = await ReadBalance();
    return {
        'title': "北京一卡通（非互联互通版）",
        '卡号': number,
        '余额': balance,
        '发卡日期': issue_date,
        '失效日期': expiry_date,
    };
};
let ReadTransShenzhen = async (fci) => {
    let r = await transceive('00B095001C');
    if (!r.endsWith('9000'))
        return {};
    const number = parseInt(r.slice(32, 40), 16);
    const issue_date = r.slice(40, 48);
    const expiry_date = r.slice(48, 56);
    const balance = await ReadBalance();
    return {
        'title': "深圳通",
        '卡号': number,
        '余额': balance,
        '发卡日期': issue_date,
        '失效日期': expiry_date,
    };
};
let ReadTransWuhan = async (fci) => {

};
let ReadCityUnion = async (fci) => {
    let f15 = await BasicInfoFile(fci);
    if (f15 == '') return {};
    const city = f15.slice(4, 8);
    let expiry_date = f15.slice(48, 56);
    if (city == '4000') { // special case for CQ
        expiry_date = f15.slice(16, 24);
        let mf = await transceive('00A40000023F00');
        if (!mf.endsWith('9000'))
            return {};
        f15 = await transceive('00B0850000');
        if (!f15.endsWith('9000'))
            return {};
    }
    const number = f15.slice(24, 40);
    const issue_date = f15.slice(40, 48);
    const balance = await ReadBalance();
    return {
        'title': `城市一卡通（${city}）`,
        '卡号': number,
        '余额': balance,
        '发卡日期': issue_date,
        '失效日期': expiry_date,
    };
};
let ReadTHU = async (fci) => {
    let f16 = await transceive('00B0960026');
    if (!f16.endsWith('9000'))
        return {};
    const name = ParseGBKText(f16.slice(0, 40).replace(/(00)+$/, ''));
    const stuNum = ParseGBKText(f16.slice(56, 76));
    const balance = await ReadBalance();
    let mf = await transceive('00A40000023F00');
    if (!mf.endsWith('9000'))
        return {};
    let f15 = await transceive('00B0950021');
    if (!f15.endsWith('9000'))
        return {};
    const number = f15.slice(12, 20);
    const dueDate = '20' + f15.slice(24, 30);
    const writtenDueDate = '20' + f15.slice(30, 36);
    return {
        'title': "清华大学校园卡",
        '卡号': number,
        '实际有效期': dueDate,
        '卡面有效期': writtenDueDate,
        '姓名': name,
        '学号/工号': stuNum,
        '余额': balance
    };
};
let ReadTUnion = async (fci) => {

};
let ReadqPBOC = async (fci) => {

};
let ReadAnyCard = async () => {
    const tag = JSON.parse(await poll());
    let r = await transceive('00B08400020');
    if (r.endsWith('9000') && r.startsWith('10007510'))
        return await ReadTransBeijing(r.slice(0, -4));
    r = await transceive('00A4040009A0000000038698070100');
    if (r.endsWith('9000')) {
        if (tag.standard === "ISO 14443-4 (Type B)")
            return await ReadTHU(r.slice(0, -4));
        return await ReadCityUnion(r.slice(0, -4));
    }
    r = await transceive('00A404000E325041592E5359532E444446303100');
    if (r.endsWith('9000')) {
        r.slice(0, -4)
        return await ReadTUnion(r);
    }
    r = await transceive('00A4000002100100');
    if (r.endsWith('9000')) {
        r.slice(0, -4)
        return await ReadTransShenzhen(r);
    }
    return {};
};
(async function () {
    let result = await ReadAnyCard();
    if (!('title' in result))
        result.title = '未知卡片';
    report(result);
})();
