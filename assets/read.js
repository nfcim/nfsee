(async function () {
    const GBKDecoder = new TextDecoder('gbk');
    const EMV_AID2NAME = {
        'A000000333010101': '银联借记卡',
        'A000000333010102': '银联信用卡',
        'A000000333010103': '银联准贷记卡',
        'A0000000031010': 'VISA卡',
        'A0000000041010': 'MasterCard',
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

    let ReadBalance = async (usage) => {
        usage = usage || 2;
        const rapdu = await transceive(`805C000${usage}04`);
        if (!rapdu.endsWith('9000'))
            return 'N/A';
        return parseInt(rapdu.slice(0, 8), 16) % 0x80000000 / 100 + '元';
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
        const balance = await ReadBalance();
        return {
            'title': "北京一卡通（非互联互通版）",
            'card_number': number,
            'balance': balance,
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
        const balance = await ReadBalance();
        return {
            'title': "深圳通",
            'card_number': number,
            'balance': balance,
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ReadTransWuhan = async (fci) => {
        const balance = await ReadBalance();
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
            'balance': balance,
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };

    };

    let ReadCityUnion = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let city = f15.slice(4, 8);
        const balance = await ReadBalance();
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
            'balance': balance,
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
        const balance = await ReadBalance(1);
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
            'balance': balance
        };
    };

    let ReadTUnion = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let f17 = await transceive('00B097000B');
        if (!f17.endsWith('9000'))
            return {};
        const balance = await ReadBalance();
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
            'balance': balance,
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
        const name = EMV_AID2NAME[DFName];
        log(`PPSE DF Name: ${DFName} (${name})`);
        if (!name) return {};
        fci = await transceive('00A40400' + buf2hex(select));
        if (!fci.endsWith('9000')) return {};
        let pdol = ExtractFromTLV(fci, ['6F', 'A5', '9F38']);
        pdol = BuildRespOfPDOL(pdol);
        if (!pdol) return {};
        pdol = buf2hex(new Uint8Array([pdol.length / 2 + 2, 0x83, pdol.length / 2])) + pdol
        const gpo_resp = await transceive(`80A80000${pdol}00`);
        log("GPO: " + gpo_resp);
        if (!gpo_resp.endsWith('9000')) return {};
        let track2 = ExtractFromTLV(gpo_resp, ['77', '57']);
        let atc = ExtractFromTLV(gpo_resp, ['77', '9F36']);
        if (!track2) {
            // None-PPSE procedure
            const AIP_AFL = ExtractFromTLV(gpo_resp, ['80']);
            if (!AIP_AFL) return {};
            log("AIP-AFL " + AIP_AFL);
            // TODO: Read record as per AFL
            return {};
        }
        track2 = buf2hex(track2);
        const sep = track2.indexOf('D');
        if (sep < 0) return {};
        if (atc) {
            atc = atc[0] << 8 | atc[1];
        }
        return {
            'title': name,
            'card_number': track2.slice(0, sep),
            'expiration': track2.slice(sep + 1, sep + 3) + '/' + track2.slice(sep + 3, sep + 5),
            'atc': atc,
        }
    };

    let ReadLingnanTong = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let r = await transceive('00A40400085041592E5449434C00');
        if (!r.endsWith('9000'))
            return {};
        const number = f15.slice(22, 32);
        const balance = await ReadBalance();
        return {
            'title': '岭南通',
            'card_number': number,
            'balance': balance,
        };
    };

    let ReadAnyCard = async () => {
        const tag = await poll();
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
