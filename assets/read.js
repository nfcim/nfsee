(async function () {
    const GBKDecoder = new TextDecoder('gbk');
    const EMV_AID2NAME = [
        ['A000000333010101', '银联借记卡'],
        ['A000000333010102', '银联信用卡'],
        ['A000000333010103', '银联准贷记卡'],
        ['A000000003', 'VISA'],
        ['A000000004', 'MasterCard'],
        ['A000000025', 'American Express'],
        ['A000000065', 'JCB'],
        ['A000000098', 'VISA USA'],
        ['A000000152', 'Discover'],
    ];
    const PBOC_TTI2NAME = {
        '01': '充值',
        '02': '充值',
        '05': '消费',
        '06': '消费',
        '09': '复合消费', // GB/T 31778
    };

    let ParseGBKText = (hexStr) => {
        return GBKDecoder.decode(hex2buf(hexStr));
    };

    let ExtractFromTLV = (hexStr, tagPath) => {
        try {
            let tlvList = TlvFactory.parse(hexStr);
            let value = null;
            for (const wanted of tagPath) {
                let found = false;
                for (const tlvObj of tlvList) {
                    if (tlvObj.tag === wanted) {
                        value = tlvObj.value;
                        tlvList = tlvObj.items;
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    console.error('tag not found:', wanted);
                    return null;
                }
            }
            return value;
        } catch (err) {
            console.error('except', err);
        }
        return null;
    };

    let BuildRespOfPDOL = (pdol) => {
        const ans2pdol = {
            0x9F66: '26000000',
            0x9F02: '000000000001',
            0x9F03: '000000000000',
            0x9F1A: '0156',
            0x95: '0000000000',
            0x5F2A: '0156',
            0x9A: '200331',
            0x9C: '00',
            0x9F37: '11223344',
        };
        try {
            let resp = '';
            for (let i = 0; i < pdol.length; i++) {
                let tag = pdol[i];
                if ((tag & 0x1F) === 0x1F)
                    tag = (tag << 8) | pdol[++i];
                let len = pdol[++i];
                if (tag in ans2pdol)
                    resp += ans2pdol[tag];
                else {
                    resp += '00'.repeat(len);
                    log(`Unknown tag ${tag} in PDOL`);
                }
            }
            return resp;
        } catch (error) {
            log("error: " + error);
            return null;
        }
    };

    let FetchElementsFromAFL = async (afl, tag_list) => {
        let ret = {};
        try {
            for (let i = 0; i < afl.length; i += 4) {
                log(`Reading record ${afl[i + 1]}~${afl[i + 2]} of SFI ${afl[i]}`);
                for (let j = afl[i + 1]; j <= afl[i + 2]; j++) {
                    const apdu = Uint8Array.from([0, 0xB2, j, 0x4 | afl[i], 0]);
                    const r = await transceive(buf2hex(apdu));
                    if (!r.endsWith('9000')) continue;
                    for (const tag of tag_list) {
                        const v = ExtractFromTLV(r, ['70', tag])
                        if (v) ret[tag] = v;
                    }
                }
            }
        } catch (error) {
            log("error: " + error);
        }
        return ret;
    };

    let ReadPBOCBalanceAndTrans = async (usage) => {
        let balance = 'N/A';
        let trans = [];
        let purchase_atc = 0;
        usage = usage || 2;
        let rapdu = await transceive(`805C000${usage}04`);
        if (rapdu.endsWith('9000'))
            balance = parseInt(rapdu.slice(0, 8), 16) % 0x80000000;
        for (let i = 1; i <= 10; i++) {
            const apdu = buf2hex(Uint8Array.from([0, 0xB2, i, 0xC4, 0]));
            rapdu = await transceive(apdu);
            if (!rapdu.endsWith('9000'))
                break;
            if (purchase_atc === 0)
                purchase_atc = parseInt(rapdu.slice(0, 4), 16);
            trans.push({
                'number': parseInt(rapdu.slice(0, 4), 16),
                'amount': parseInt(rapdu.slice(10, 18), 16) % 0x80000000,
                'type': PBOC_TTI2NAME[rapdu.slice(18, 20)] || '',
                'terminal': rapdu.slice(20, 32),
                'date': rapdu.slice(32, 40),
                'time': rapdu.slice(40, 46),
            });
        }
        let load_atc = undefined;
        rapdu = await transceive('805000020B0100000001000000000000');
        if (rapdu.endsWith('9000'))
            load_atc = parseInt(rapdu.slice(8, 12), 16);
        return [balance, purchase_atc, load_atc, trans];
    };

    let BasicInfoFile = async (fci) => {
        let r = ExtractFromTLV(fci, ['6F', 'A5', '9F0C']);
        if (r) return buf2hex(r);
        r = await transceive('00B095001E');
        if (!r.endsWith('9000'))
            return '';
        return r.slice(0, -4);
    };

    let ReadTransBeijing = async (content04) => {
        let r = await transceive('00A4000002100100');
        if (!r.endsWith('9000'))
            return {};
        const number = content04.slice(0, 16);
        const issue_date = content04.slice(48, 56);
        const expiry_date = content04.slice(56, 64);
        const balance_atc_trans = await ReadPBOCBalanceAndTrans();
        return {
            'title': "北京一卡通（非互联互通版）",
            'card_number': number,
            'balance': balance_atc_trans[0],
            'purchase_atc': balance_atc_trans[1],
            'load_atc': balance_atc_trans[2],
            'transactions': balance_atc_trans[3],
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ReadTransShenzhen = async (fci) => {
        let r = await BasicInfoFile(fci);
        if (!r) return {};
        const number = parseInt(r.slice(32, 40), 16);
        const issue_date = r.slice(40, 48);
        const expiry_date = r.slice(48, 56);
        const balance_trans = await ReadPBOCBalanceAndTrans();
        return {
            'title': "深圳通",
            'card_number': number,
            'balance': balance_trans[0],
            'transactions': balance_trans[1],
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ReadTransWuhan = async (fci) => {
        const balance_trans = await ReadPBOCBalanceAndTrans();
        let mf = await transceive('00A40000023F00');
        if (!mf.endsWith('9000'))
            return {};
        let f15 = await transceive('00B0950000');
        if (!f15.endsWith('9000'))
            return {};
        let f0a = await transceive('00B08A0005');
        if (!f0a.endsWith('9000'))
            return {};
        const number = f0a.slice(0, 10);
        const issue_date = f15.slice(40, 48);
        const expiry_date = f15.slice(48, 56);
        return {
            'title': "武汉通",
            'card_number': number,
            'balance': balance_trans[0],
            'transactions': balance_trans[1],
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };

    };

    let ReadCityUnion = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let city = f15.slice(4, 8);
        const balance_trans = await ReadPBOCBalanceAndTrans();
        let expiry_date = f15.slice(48, 56);
        if (city === '4000') { // special case for Chongqing
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
        city = (city in ChinaPostCode) ? ChinaPostCode[city] : `未知代码${city}`;
        return {
            'title': `城市一卡通（${city}）`,
            'card_number': number,
            'balance': balance_trans[0],
            'transactions': balance_trans[1],
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ReadTHU = async (fci) => {
        let f16 = await transceive('00B0960026');
        if (!f16.endsWith('9000'))
            return {};
        const name = ParseGBKText(f16.slice(0, 40).replace(/(00)+$/, ''));
        const stuNum = ParseGBKText(f16.slice(56, 76));
        const balance_trans = await ReadPBOCBalanceAndTrans(1);
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
            'card_number': number,
            'expiry_date': dueDate,
            'display_expiry_date': writtenDueDate,
            'name': name,
            'number': stuNum,
            'balance': balance_trans[0],
            'transactions': balance_trans[1],
        };
    };

    let ReadTUnion = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let f17 = await transceive('00B097000B');
        if (!f17.endsWith('9000'))
            return {};
        const balance_trans = await ReadPBOCBalanceAndTrans();
        const number = f15.slice(20, 40);
        const issue_date = f15.slice(40, 48);
        const expiry_date = f15.slice(48, 56);
        const province = f17.slice(8, 12);
        let city = f17.slice(12, 16);
        let type = parseInt(f17.slice(20, 22), 16);
        type = (type in TUnionDF11Type) ? TUnionDF11Type[type] : `未知(${type})`;
        city = (city in UnionPayRegion) ? UnionPayRegion[city] : `未知代码${city}`;
        return {
            'title': "交通联合卡",
            'card_number': number,
            'balance': balance_trans[0],
            'transactions': balance_trans[1],
            'province_code': province,
            'city': city,
            'tu_type': type,
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ReadPPSE = async (fci) => {
        let DFName = ExtractFromTLV(fci, ['6F', 'A5', 'BF0C', '61', '4F']);
        if (!DFName) return {};
        const select = Uint8Array.from([DFName.length, ...DFName, 0]);
        DFName = buf2hex(DFName);
        let name = null;
        for (const item of EMV_AID2NAME) {
            if (DFName.startsWith(item[0])) {
                name = item[1];
                break;
            }
        }
        log(`PPSE DF Name: ${DFName} (${name})`);
        if (!name) return {};
        fci = await transceive('00A40400' + buf2hex(select));
        if (!fci.endsWith('9000')) return {};
        let pdol = ExtractFromTLV(fci, ['6F', 'A5', '9F38']);
        pdol = pdol ? BuildRespOfPDOL(pdol) : '';
        pdol = buf2hex(new Uint8Array([pdol.length / 2 + 2, 0x83, pdol.length / 2])) + pdol
        const gpo_resp = await transceive(`80A80000${pdol}00`);
        log("GPO: " + gpo_resp);
        if (!gpo_resp.endsWith('9000')) return {};
        let track2 = ExtractFromTLV(gpo_resp, ['77', '57']);
        let atc = ExtractFromTLV(gpo_resp, ['77', '9F36']);
        if (!track2) {
            // None-PPSE procedure
            let AFL = ExtractFromTLV(gpo_resp, ['77', '94']);
            if (!AFL) {
                const AIP_AFL = ExtractFromTLV(gpo_resp, ['80']);
                if (!AIP_AFL) return {};
                AFL = AIP_AFL.slice(2); // skip 2-byte AIP
            }
            const elements = await FetchElementsFromAFL(AFL, ['57']);
            track2 = elements['57'];
        }
        if (!atc) {
            let r = await transceive("80CA9F3600");
            if (!r.endsWith('9000')) return {};
            atc = ExtractFromTLV(r, ['9F36']);
        }
        track2 = buf2hex(track2);
        const sep = track2.indexOf('D');
        if (sep < 0) return {};
        atc = atc[0] << 8 | atc[1];
        let pin_retry = await transceive("80CA9F1700");
        if (!pin_retry.endsWith('9000')) pin_retry = 'N/A';
        else {
            pin_retry = ExtractFromTLV(pin_retry, ['9F17'])[0];
        }
        return {
            'title': name,
            'card_number': track2.slice(0, sep),
            'expiration': track2.slice(sep + 1, sep + 3) + '/' + track2.slice(sep + 3, sep + 5),
            'atc': atc,
            'pin_retry': pin_retry,
        }
    };

    let ReadLingnanTong = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let r = await transceive('00A40400085041592E5449434C00');
        if (!r.endsWith('9000'))
            return {};
        const number = f15.slice(22, 32);
        const balance_trans = await ReadPBOCBalanceAndTrans();
        return {
            'title': '岭南通',
            'card_number': number,
            'balance': balance_trans[0],
            'transactions': balance_trans[1],
        };
    };

    let ReadAnyCard = async () => {
        const tag = await poll();
        log(tag);
        let r = await transceive('00B0840020');
        if (r.endsWith('9000') && r.startsWith('1000'))
            return await ReadTransBeijing(r.slice(0, -4));
        r = await transceive('00A4040009A0000000038698070100');
        if (r.endsWith('9000')) {
            if (tag.standard === "ISO 14443-4 (Type B)")
                return await ReadTHU(r.slice(0, -4));
            return await ReadCityUnion(r.slice(0, -4));
        }
        r = await transceive('00A4040008A00000063201010500');
        if (r.endsWith('9000')) {
            r = r.slice(0, -4);
            return await ReadTUnion(r);
        }
        r = await transceive('00A404000E325041592E5359532E444446303100');
        if (r.endsWith('9000')) {
            r = r.slice(0, -4);
            return await ReadPPSE(r);
        }
        r = await transceive('00A4000002100100');
        if (r.endsWith('9000')) {
            r = r.slice(0, -4);
            let DFName = ExtractFromTLV(r, ['6F', '84']);
            if (DFName) {
                DFName = GBKDecoder.decode(DFName);
                if (DFName.startsWith('PAY.SZT'))
                    return await ReadTransShenzhen(r);
                else if (DFName.startsWith('AP1.WHCTC'))
                    return await ReadTransWuhan(r);
            }
        }
        r = await transceive('00A40400085041592E4150505900');
        if (r.endsWith('9000')) {
            r = r.slice(0, -4);
            return await ReadLingnanTong(r);
        }
        return {};
    };

    let result = await ReadAnyCard();
    if (!('title' in result))
        result.title = '未知卡片';
    report(result);
})();
