(async function () {
    const GBKDecoder = new TextDecoder('gbk');
    const EMV_AID2NAME = [
        ['A000000333010101', 'UPDebit'],
        ['A000000333010102', 'UPCredit'],
        ['A000000333010103', 'UPSecuredCredit'],
        ['A000000003', 'Visa'],
        ['A000000004', 'MC'],
        ['A000000025', 'AMEX'],
        ['A000000065', 'JCB'],
        ['A000000324', 'Discover'],
    ];
    const PBOC_TTI2NAME = {
        '01': 'Load',
        '02': 'Load',
        '05': 'Purchase',
        '06': 'Purchase',
        '09': 'CompoundPurchase', // GB/T 31778
    };
    const TMoney_TTI2NAME = {
        '01': 'Purchace',
        '02': 'Load',
    };
    const ISO8583_ProcessingCode2Name = {
        '00': 'Authorization',
        '31': 'BalanceInquiry',
        '01': 'Cash',
        '02': 'Void',
        '57': 'MobileTopup',
    };
    const BJ_Subway_ID2NAME = {
        '01': 'Line1',
        '02': 'Line2',
        '04': 'Line4',
        '05': 'Line5',
        '06': 'Line6',
        '07': 'Line7',
        '08': 'Line8',
        '09': 'Line9',
        '10': 'Line10',
        '13': 'Line13',
        '14': 'Line14',
        '15': 'Line15',
        '16': 'Line16',
        '18': 'Xijiao',
        '88': 'DaxingAirport',
        '93': 'Daxing',
        '94': 'Changping',
        '95': 'Fangshan',
        '96': 'Yizhuang',
        '97': 'Batong',
        '98': 'CapitalAirport',
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
                    const r = await _transceive(buf2hex(apdu));
                    if (!r.endsWith('9000')) continue;
                    for (const tag of tag_list) {
                        const v = ExtractFromTLV(r, ['70', tag]);
                        if (v) ret[tag] = v;
                    }
                }
            }
        } catch (error) {
            log("error: " + error);
        }
        return ret;
    };

    let ReadPPSETransactions = async (log_entry, log_format) => {
        log_format = ExtractFromTLV(log_format, ['9F4F']);
        const sfi = log_entry[0];
        const total = log_entry[1];
        let trans = [];
        try {
            for (let n = 1; n <= total; n++) {
                const apdu = buf2hex(Uint8Array.from([0, 0xB2, n, sfi << 3 | 4, 0]));
                rapdu = await _transceive(apdu);
                if (!rapdu.endsWith('9000'))
                    break;
                let off = 0;
                let item = {};
                const century = (new Date).getFullYear().toFixed().slice(0, 2);
                for (let i = 0; i < log_format.length; i++) {
                    let tag = log_format[i];
                    if ((tag & 0x1F) === 0x1F)
                        tag = (tag << 8) | log_format[++i];
                    let len = log_format[++i];
                    let extractField = () => {
                        return rapdu.slice(2 * off, 2 * (off + len));
                    };
                    switch (tag) {
                        case 0x9A:
                            item['date'] = century + extractField();
                            break;
                        case 0x9F21:
                            item['time'] = extractField();
                            break;
                        case 0x81:
                            item['amount'] = parseInt(extractField(), 16);
                            break;
                        case 0x9F02:
                            item['amount'] = parseInt(extractField(), 10);
                            break;
                        case 0x9F04:
                            item['amount_other'] = parseInt(extractField(), 16);
                            break;
                        case 0x9F03:
                            item['amount_other'] = parseInt(extractField(), 10);
                            break;
                        case 0x9F1A:
                            item['country_code'] = extractField().slice(1);
                            break;
                        case 0x5F2A:
                            item['currency'] = ISO4217CurrencyCode[extractField().slice(1)];
                            break;
                        case 0x9F4E:
                            item['terminal'] = extractField();
                            break;
                        case 0x9C:
                            item['type'] = ISO8583_ProcessingCode2Name[extractField()];
                            break;
                        case 0x9F36:
                            item['number'] = parseInt(extractField(), 16);
                            break;

                        default:
                            log(`Unknown tag ${tag} in log format`);
                    }
                    off += len;
                }
                trans.push(item);
            }
        } catch (error) {
            log("error: " + error);
        }
        return trans;
    };

    let ReadPBOCBalanceATCAndTrans = async (usage) => {
        let balance = 'N/A';
        let trans = [];
        let purchase_atc = 0;
        usage = usage || 2;
        let rapdu = await _transceive(`805C000${usage}04`);
        if (rapdu.endsWith('9000'))
            balance = parseInt(rapdu.slice(0, 8), 16) % 0x80000000;
        for (let i = 1; i <= 10; i++) {
            const apdu = buf2hex(Uint8Array.from([0, 0xB2, i, 0xC4, 0x17]));
            rapdu = await _transceive(apdu);
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
        rapdu = await _transceive(`8050000${usage}0B010000000100000000000010`);
        if (rapdu.endsWith('9000'))
            load_atc = parseInt(rapdu.slice(8, 12), 16);
        return [balance, purchase_atc, load_atc, trans];
    };

    let BasicInfoFile = async (fci) => {
        let r = ExtractFromTLV(fci, ['6F', 'A5', '9F0C']);
        if (r) return buf2hex(r);
        r = await _transceive('00B095001E');
        if (!r.endsWith('9000'))
            return '';
        return r.slice(0, -4);
    };

    let ReadTransBeijing = async (content04) => {
        let r = await _transceive('00A4000002100100');
        if (!r.endsWith('9000'))
            return {};
        const number = content04.slice(0, 16);
        const issue_date = content04.slice(48, 56);
        const expiry_date = content04.slice(56, 64);
        let balance_atc_trans = await ReadPBOCBalanceATCAndTrans();
        for (let item of balance_atc_trans[3]) {
            if (item.terminal.startsWith('300') && item.terminal.slice(3, 5) in BJ_Subway_ID2NAME)
                item['subway_exit'] = BJ_Subway_ID2NAME[item.terminal.slice(3, 5)];
        }
        return {
            'card_type': 'BMAC',
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
        const number = parseInt(r.slice(32, 40), 16).toString();
        const issue_date = r.slice(40, 48);
        const expiry_date = r.slice(48, 56);
        const balance_atc_trans = await ReadPBOCBalanceATCAndTrans();
        return {
            'card_type': 'ShenzhenTong',
            'card_number': number,
            'balance': balance_atc_trans[0],
            'purchase_atc': balance_atc_trans[1],
            'load_atc': balance_atc_trans[2],
            'transactions': balance_atc_trans[3],
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ReadMacauPass = async (fci) => {
        let r = await BasicInfoFile(fci);
        if (!r) return {};
        const number = r.slice(70, 80);
        const issue_date = r.slice(40, 48);
        const expiry_date = r.slice(48, 56);
        const balance_atc_trans = await ReadPBOCBalanceATCAndTrans();
        const balance = balance_atc_trans[0] * 10 - 1000;
        const trans = balance_atc_trans[3];
        for (let i in trans) {
            trans[i].amount *= 10; // in $0.01
        }
        return {
            'card_type': 'MacauPass',
            'card_number': number,
            'balance': balance,
            'purchase_atc': balance_atc_trans[1],
            'load_atc': balance_atc_trans[2],
            'transactions': trans,
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ReadTransWuhan = async () => {
        const balance_atc_trans = await ReadPBOCBalanceATCAndTrans();
        let mf = await _transceive('00A40000023F00');
        if (!mf.endsWith('9000'))
            return {};
        let f15 = await _transceive('00B095001C');
        if (!f15.endsWith('9000'))
            return {};
        let f0a = await _transceive('00B08A0005');
        if (!f0a.endsWith('9000'))
            return {};
        const number = f0a.slice(0, 10);
        const issue_date = f15.slice(40, 48);
        const expiry_date = f15.slice(48, 56);
        return {
            'card_type': 'WuhanTong',
            'card_number': number,
            'balance': balance_atc_trans[0],
            'purchase_atc': balance_atc_trans[1],
            'load_atc': balance_atc_trans[2],
            'transactions': balance_atc_trans[3],
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };

    };

    let ReadCityUnion = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let city = f15.slice(4, 8);
        const balance_atc_trans = await ReadPBOCBalanceATCAndTrans();
        let expiry_date = f15.slice(48, 56);
        if (city === '4000') { // special case for Chongqing
            expiry_date = f15.slice(16, 24);
            let mf = await _transceive('00A40000023F00');
            if (!mf.endsWith('9000'))
                return {};
            f15 = await _transceive('00B0850030');
            if (!f15.endsWith('9000'))
                return {};
        }
        const number = f15.slice(24, 40);
        const issue_date = f15.slice(40, 48);
        city = (city in ChinaPostCode) ? ChinaPostCode[city] : `未知代码${city}`;
        return {
            'card_type': 'CityUnion',
            'city': city,
            'card_number': number,
            'balance': balance_atc_trans[0],
            'purchase_atc': balance_atc_trans[1],
            'load_atc': balance_atc_trans[2],
            'transactions': balance_atc_trans[3],
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ReadTHU = async () => {
        let f16 = await _transceive('00B0960026');
        if (!f16.endsWith('9000'))
            return {};
        const name = ParseGBKText(f16.slice(0, 40).replace(/(00)+$/, ''));
        const stuNum = ParseGBKText(f16.slice(56, 76));
        const balance_atc_trans = await ReadPBOCBalanceATCAndTrans(1);
        let mf = await _transceive('00A40000023F00');
        if (!mf.endsWith('9000'))
            return {};
        let f15 = await _transceive('00B0950021');
        if (!f15.endsWith('9000'))
            return {};
        const number = f15.slice(12, 20);
        const dueDate = '20' + f15.slice(24, 30);
        const writtenDueDate = '20' + f15.slice(30, 36);
        return {
            'card_type': 'Tsinghua',
            'name': name,
            'card_number': stuNum,
            'internal_number': number,
            'expiry_date': dueDate,
            'display_expiry_date': writtenDueDate,
            'balance': balance_atc_trans[0],
            'purchase_atc': balance_atc_trans[1],
            'load_atc': balance_atc_trans[2],
            'transactions': balance_atc_trans[3],
        };
    };

    let ReadTUnion = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let f17 = await _transceive('00B097000B');
        if (!f17.endsWith('9000'))
            return {};
        const balance_atc_trans = await ReadPBOCBalanceATCAndTrans();
        const number = f15.slice(20, 40);
        const issue_date = f15.slice(40, 48);
        const expiry_date = f15.slice(48, 56);
        let province = f17.slice(8, 12);
        let city = f17.slice(12, 16);
        let type = parseInt(f17.slice(20, 22), 16);
        type = (type in TUnionDF11Type) ? TUnionDF11Type[type] : `(${type})`;
        city = (city in UnionPayRegion) ? UnionPayRegion[city] : `(${city})`;
        province = (province in UnionPayRegion) ? UnionPayRegion[province] : `(${province})`;
        return {
            'card_type': 'TUnion',
            'card_number': number.replace(/^0+/, ''),
            'balance': balance_atc_trans[0],
            'purchase_atc': balance_atc_trans[1],
            'load_atc': balance_atc_trans[2],
            'transactions': balance_atc_trans[3],
            'province': province,
            'city': city,
            'tu_type': type,
            'issue_date': issue_date,
            'expiry_date': expiry_date,
        };
    };

    let ParseTrack2Eqiv = (tr2eqiv) => {
        tr2eqiv = buf2hex(tr2eqiv);
        const sep = tr2eqiv.indexOf('D');
        if (sep < 0) return null;
        return [tr2eqiv.slice(0, sep),
        tr2eqiv.slice(sep + 1, sep + 3) + '/' + tr2eqiv.slice(sep + 3, sep + 5)];
    };

    let ParseTrack1 = (tr1) => {
        let text = GBKDecoder.decode(tr1);
        let groups = text.match(/^B([0-9]{1,19})\^([^\^]{2,26})\^(([0-9]{2})([0-9]{2})|\^)/);
        if (groups === null || groups.length < 6) return null;
        return [groups[1], groups[4] + '/' + groups[5]];
    };

    let ReadPPSE = async (fci) => {
        let DFName = ExtractFromTLV(fci, ['6F', 'A5', 'BF0C', '61', '4F']);
        if (!DFName) return {};
        const select = Uint8Array.from([DFName.length, ...DFName, 0]);
        DFName = buf2hex(DFName);
        let cardType = null;
        for (const item of EMV_AID2NAME) {
            if (DFName.startsWith(item[0])) {
                cardType = item[1];
                break;
            }
        }
        log(`PPSE DF Name: ${DFName} (${cardType})`);
        if (!cardType) return {};
        fci = await _transceive('00A40400' + buf2hex(select));
        if (!fci.endsWith('9000')) return {};
        const log_entry = ExtractFromTLV(fci, ['6F', 'A5', 'BF0C', '9F4D']);
        let pdol = ExtractFromTLV(fci, ['6F', 'A5', '9F38']);
        pdol = pdol ? BuildRespOfPDOL(pdol) : '';
        pdol = buf2hex(new Uint8Array([pdol.length / 2 + 2, 0x83, pdol.length / 2])) + pdol;
        const gpo_resp = await _transceive(`80A80000${pdol}00`);
        log("GPO: " + gpo_resp);
        if (!gpo_resp.endsWith('9000')) return {};
        let track2eqiv = ExtractFromTLV(gpo_resp, ['77', '57']);
        let atc = ExtractFromTLV(gpo_resp, ['77', '9F36']);
        let pan = '';
        let expiration = '';
        if (!track2eqiv) {
            // None-PPSE procedure
            let AFL = ExtractFromTLV(gpo_resp, ['77', '94']);
            if (!AFL) {
                const AIP_AFL = ExtractFromTLV(gpo_resp, ['80']);
                if (!AIP_AFL) return {};
                AFL = AIP_AFL.slice(2); // skip 2-byte AIP
            }
            const elements = await FetchElementsFromAFL(AFL, ['56', '57', '9F6B']);
            track2eqiv = elements['57'] || elements['9F6B'];
            if (track2eqiv)
                [pan, expiration] = ParseTrack2Eqiv(track2eqiv);
            else if (elements['56'])
                [pan, expiration] = ParseTrack1(elements['56']);
            else
                return {};
        } else {
            [pan, expiration] = ParseTrack2Eqiv(track2eqiv);
        }
        if (!atc) {
            let r = await _transceive("80CA9F3600");
            if (r.endsWith('9000'))
                atc = ExtractFromTLV(r, ['9F36']);
        }
        if (!atc)
            atc = 'N/A';
        else
            atc = atc[0] << 8 | atc[1];
        let pin_retry = await _transceive("80CA9F1700");
        if (!pin_retry.endsWith('9000')) pin_retry = 'N/A';
        else {
            pin_retry = ExtractFromTLV(pin_retry, ['9F17'])[0];
        }
        let transactions = [];
        let log_format = await _transceive("80CA9F4F00");
        if (log_format.endsWith('9000') && log_entry) {
            transactions = await ReadPPSETransactions(log_entry, log_format);
        }
        return {
            'card_type': cardType,
            'card_number': pan,
            'expiration': expiration,
            'atc': atc,
            'transactions': transactions,
            'pin_retry': pin_retry,
        }
    };

    let ReadLingnanTong = async (fci) => {
        let f15 = await BasicInfoFile(fci);
        if (f15 === '') return {};
        let r = await _transceive('00A40400085041592E5449434C00');
        if (!r.endsWith('9000'))
            return {};
        const number = f15.slice(22, 32);
        const balance_atc_trans = await ReadPBOCBalanceATCAndTrans();
        return {
            'card_type': 'LingnanPass',
            'card_number': number,
            'balance': balance_atc_trans[0],
            'purchase_atc': balance_atc_trans[1],
            'load_atc': balance_atc_trans[2],
            'transactions': balance_atc_trans[3],
        };
    };

    let ReadTMoney = async (fci) => {
        let purse_info = fci.slice(8);
        if (!purse_info) {
            return {};
        }
        const number = purse_info.slice(24, 34);
        const issue_date = purse_info.slice(34, 42);
        const expiry_date = purse_info.slice(42, 50);
        let balance = 'N/A';
        let rapdu = await _transceive('904C000004');
        if (rapdu.endsWith('9000')) {
            balance = parseInt(rapdu.slice(0, 8), 16);
            console.log(balance);
        }
        let balance_records = [];
        // read balance records
        for (let i = 1; i <= 10; i++) {
            const apdu = buf2hex(Uint8Array.from([0, 0xB2, i, 0x24, 0x2E]));
            rapdu = await _transceive(apdu);
            if (!rapdu.endsWith('9000'))
                break;
            balance_records.push({
                'type': TMoney_TTI2NAME[rapdu.slice(0, 2)] || '',
                'number': parseInt(rapdu.slice(8, 10), 16),
                'balance_after': parseInt(rapdu.slice(4, 12), 16),
                'transaction_couter': parseInt(rapdu.slice(12, 20), 16),
                'amount': parseInt(rapdu.slice(20, 28), 16),
                'terminal': rapdu.slice(28, 37),
            });
        }
        return {
            'card_type': 'TMoney',
            'card_number': number,
            'balance': balance,
            'issue_date': issue_date,
            'expiry_date': expiry_date,
            'transactions': balance_records,
        }
    }

    let ReadChinaID = async (ic_serial) => {
        let r = await _transceive('00A40000026002');
        if (!r.endsWith('900000'))
            return {};
        r = await _transceive('80B0000020');
        if (!r.endsWith('900000'))
            return {};
        const mgmt_number = r.slice(0, 32);
        return {
            'card_type': 'ChinaResidentIDGen2',
            'ic_serial': ic_serial,
            'mgmt_number': mgmt_number,
        };
    };

    let ReadOctopus = async () => {
        const sysCode = 0x0880;
        const balanceSrvCode = 0x0117;
        const f = new Felica(_transceive);
        const idm_pmm = await f.polling(sysCode);
        const balance = await f.readWithoutEncryption(balanceSrvCode, 0);
        if (balance === null)
            return { 'card_type': 'Unknown' };
        let balance_num = parseInt(balance.slice(0, 8), 16);
        // balance in units of 0.1HKD plus 500
        // convert to units of 0.01HKD
        balance_num = (balance_num - 500) * 10;
        return {
            'card_type': 'Octopus',
            'card_number': idm_pmm[0],
            'balance': balance_num,
        };
    };

    let ReadMifareUltralight = async () => {
        // get version
        let version = await _transceive('60');
        if (version.length == 16) {
            // success

            let mifare_vendor_id = version.substring(2, 4);
            let mifare_vendor = "unknown";
            if (mifare_vendor_id === "04") {
                mifare_vendor = "NXP Semiconductor";
            }
            let mifare_product_name = "unknown";

            let mifare_product_type = version.substring(4, 6);
            let mifare_product_subtype = version.substring(6, 8);
            let mifare_major_product_version = version.substring(8, 10);
            let mifare_minor_product_version = version.substring(10, 12);
            let mifare_storage_size = version.substring(12, 14);
            // most significant 7 bits = n
            // storage size = 2^n
            let storage_size = parseInt(mifare_storage_size, 16);

            mifare_storage_size = 1 << (storage_size >> 1);
            let real_storage_size = mifare_storage_size;

            if (storage_size & 1) {
                // least bit is 1
                mifare_storage_size = `Between ${mifare_storage_size} and ${mifare_storage_size * 2} bytes`;
            } else {
                // least bit is 0
                mifare_storage_size = `${mifare_storage_size} bytes`;
            }
            let mifare_protocol_type = version.substring(14, 16);

            // ref: MF0ULX1 datasheet
            if (mifare_product_type === "03") {
                mifare_product_type = "MIFARE Ultralight";

                if (mifare_major_product_version === "01") {
                    mifare_major_product_version = "EV1";
                }

                if (mifare_minor_product_version === "00") {
                    mifare_minor_product_version = "V0";
                }
            }

            // ref: NTAG213/215/216 datasheet
            if (mifare_product_type === "04") {
                mifare_product_type = "NTAG";

                if (mifare_major_product_version === "01") {
                    mifare_major_product_version = "1";
                }

                if (mifare_minor_product_version === "00") {
                    mifare_minor_product_version = "0";
                }

                if (mifare_product_subtype === "02") {
                    if (storage_size === 0x0F) {
                        mifare_product_name = "NTAG213";
                        real_storage_size = 45 * 4;
                        mifare_storage_size = `${real_storage_size} bytes`;
                    } else if (storage_size === 0x11) {
                        mifare_product_name = "NTAG215";
                        real_storage_size = 135 * 4;
                        mifare_storage_size = `${real_storage_size} bytes`;
                    } else if (storage_size === 0x13) {
                        mifare_product_name = "NTAG216";
                        real_storage_size = 231 * 4;
                        mifare_storage_size = `${real_storage_size} bytes`;
                    }
                }
            }

            if (mifare_product_subtype === "01") {
                mifare_product_subtype = "17 pF";
            } else if (mifare_product_subtype === "02") {
                mifare_product_subtype = "50 pF";
            }

            // read data from page 0, to page storage_size/4
            let data = "";
            for (let i = 0; i < real_storage_size / 4; i += 4) {
                let hex = i.toString(16);
                if (hex.length == 1) {
                    hex = "0" + hex;
                }
                data += await _transceive(`30${hex}`);
            }
            // strip extra data
            data = data.substring(0, real_storage_size * 2);

            return {
                'card_type': 'MifareUltralight',
                data,
                mifare_vendor,
                mifare_product_type,
                mifare_product_subtype,
                mifare_product_version: `${mifare_major_product_version} ${mifare_minor_product_version}`,
                mifare_product_name,
                mifare_storage_size,
            };
        } else {
            return {};
        }
    };

    let ReadMifarePlus = async () => {
        return { 'card_type': 'MifarePlus' };
    };

    let ReadMifareDESFire = async (hardware_version) => {
        let mifare_vendor_id = hardware_version.substring(0, 2);
        let mifare_vendor = "unknown";
        if (mifare_vendor_id === "04") {
            mifare_vendor = "NXP Semiconductor";
        }

        let mifare_product_type = hardware_version.substring(2, 4);
        let mifare_product_subtype = hardware_version.substring(4, 6);
        let mifare_major_product_version = hardware_version.substring(6, 8);
        let mifare_minor_product_version = hardware_version.substring(8, 10);

        let mifare_storage_size = hardware_version.substring(10, 12);
        // most significant 7 bits = n
        // storage size = 2^n
        let storage_size = parseInt(mifare_storage_size, 16);

        mifare_storage_size = 1 << (storage_size >> 1);

        if (storage_size & 1) {
            // least bit is 1
            mifare_storage_size = `Between ${mifare_storage_size} and ${mifare_storage_size * 2} bytes`;
        } else {
            // least bit is 0
            mifare_storage_size = `${mifare_storage_size} bytes`;
        }

        // af: more data
        let software_vesion = await _transceive('90af000000');
        // af: more data
        let more_info = await _transceive('90af000000');
        // BCD
        let week = parseInt(more_info.substring(24, 26));
        let year = parseInt(more_info.substring(26, 28));
        let mifare_production_date = `week ${week} of year 20${year}`;

        return {
            'card_type': 'MifareDESFire',
            mifare_vendor,
            mifare_product_type,
            mifare_product_subtype,
            mifare_product_version: `${mifare_major_product_version} ${mifare_minor_product_version}`,
            mifare_storage_size,
            mifare_production_date,
        };
    };

    let ReadMifareClassic = async (tag) => {
        let data = "";
        // MAD public key and NDEF public keys
        let keys = ["A0A1A2A3A4A5", "D3F7D3F7D3F7", "D3F7D3F7D3F7"];
        for (let sector = 0; sector < 3; sector += 1) {
            try {
                // authenticate key a with public key
                let begin_block = sector * 4;
                await _transceive(`600${begin_block.toString(16)}${tag.id}${keys[sector]}`);
                // four blocks each sector
                data += await _transceive(`300${(begin_block + 0).toString(16)}`);
                data += await _transceive(`300${(begin_block + 1).toString(16)}`);
                data += await _transceive(`300${(begin_block + 2).toString(16)}`);
                data += await _transceive(`300${(begin_block + 3).toString(16)}`);
            } catch (e) {
                // allow to fail
                break;
            }
        }
        return { 'card_type': 'MifareClassic', data };
    };

    let ReadAnyCard = async (tag) => {
        if (tag.type === "felica" && tag.systemCode === "8008") {
            // Octopus
            return await ReadOctopus();
        } else if (tag.type === "mifare_ultralight") {
            return await ReadMifareUltralight();
        } else if (tag.type === "mifare_plus") {
            return await ReadMifarePlus();
        } else if (tag.type === "mifare_classic") {
            return await ReadMifareClassic(tag);
        } else if (tag.standard === "ISO 14443-3 (Type B)") {
            // ChinaResidentID
            let r = await _transceive('0036000008');
            if (r.endsWith('900000'))
                return await ReadChinaID(r.slice(0, 16));
        } else if (tag.standard === "ISO 14443-4 (Type A)") {
            // TransBeijing
            let r = await _transceive('00B0840020');
            if (r.endsWith('9000') && r.startsWith('1000')) {
                return await ReadTransBeijing(r.slice(0, -4));
            }

            // MIFARE DESFire GetVersion: 60
            r = await _transceive('9060000000');
            if (r.endsWith('91AF')) {
                return await ReadMifareDESFire(r.slice(0, -4));
            }

            // CityUnion
            r = await _transceive('00A4040009A0000000038698070100');
            if (r.endsWith('9000')) {
                return await ReadCityUnion(r.slice(0, -4));
            }

            // TUnion
            r = await _transceive('00A4040008A00000063201010500');
            if (r.endsWith('9000')) {
                r = r.slice(0, -4);
                return await ReadTUnion(r);
            }

            // TransShenzhen / TransWuhan
            r = await _transceive('00A4000002100100');
            if (r.endsWith('9000')) {
                r = r.slice(0, -4);
                let DFName = ExtractFromTLV(r, ['6F', '84']);
                if (DFName) {
                    const DFNameHex = buf2hex(DFName);
                    // log("DFName in hex: " + DFNameHex);
                    if (DFNameHex === 'B0C4C3C5CDA8C7AEB0FC')
                        return await ReadMacauPass(r);
                    DFName = GBKDecoder.decode(DFName);
                    if (DFName.startsWith('PAY.SZT'))
                        return await ReadTransShenzhen(r);
                    else if (DFName.startsWith('AP1.WHCTC'))
                        return await ReadTransWuhan();
                }
            }

            // LingnanTong
            r = await _transceive('00A40400085041592E4150505900');
            if (r.endsWith('9000')) {
                r = r.slice(0, -4);
                return await ReadLingnanTong(r);
            }

            // T-Money
            // TODO 
            r = await _transceive('00A4040007D410000003000100');
            if (r.endsWith('9000')) {
                console.log("TMoney");
                r = r.slice(0, -4);
                return await ReadTMoney(r);
            }

            // put it here because iOS fails here
            // PPSE
            r = await _transceive('00A404000E325041592E5359532E444446303100');
            if (r.endsWith('9000')) {
                r = r.slice(0, -4);
                return await ReadPPSE(r);
            }
        } else if (tag.standard === "ISO 14443-4 (Type B)") {
            // THU
            r = await _transceive('00A4040009A0000000038698070100');
            if (r.endsWith('9000')) {
                return await ReadTHU();
            }
        }

        // unsupported
        return { 'card_type': 'Unknown' };
    };

    let getWrappedTransceive = (apdu_history, tagType) => {
        return async (apdu) => {
            const result = await transceive(apdu);
            let history = {
                'tx': apdu,
                'rx': result
            };
            // append success history only
            if (tagType != 'iso7816' || result.endsWith('9000')) {
                apdu_history.push(history);
            }
            return result;
        };
    }

    let _transceive = null;

    try {
        // record APDU history
        let apdu_history = [];
        // poll a tag
        const tag = await poll();
        log(tag);
        // read detailed information
        var _card_type = 'Unknown';
        var detail = {};
        _transceive = getWrappedTransceive(apdu_history, tag.type);
        try {
            let { card_type, ..._detail } = await ReadAnyCard(tag);
            if (card_type) {
                _card_type = card_type;
            }
            Object.assign(detail, _detail);
            // pass ndef struct to detail
            detail["ndef"] = tag["ndef"];
            delete tag["ndef"];
        } catch (e) {
            log(`Script error when reading detail: ${JSON.stringify(e)}`);
        }
        // return to invoker
        const result = {
            tag,
            card_type: _card_type,
            detail,
            apdu_history
        };
        report(result);
    } catch (e) {
        log(`Script error when polling: ${JSON.stringify(e)}`);
    } finally {
        finish();
    }
})();
