class Felica {
    constructor(transceive) {
        this.transceive = transceive;
    }
    async sendCommand(cmd, payload) {
        if (cmd != this.CMD_POLLING) {
            const idm_buf = new Uint8Array(hex2buf(this.idm));
            payload = Array.from(idm_buf).concat(payload);
        }
        let buf = Uint8Array.from([payload.length+2, cmd, ...payload]);
        let resp = await this.transceive(buf2hex(buf));
        if(!resp || resp.length < 20) {
            throw new Error("Invalid Felica response");
        }
        this.idm = resp.slice(4, 20);
        return resp;
    }
    async polling(systemCode) {
        let r = await this.sendCommand(this.CMD_POLLING, [
            systemCode & 0xff, systemCode >> 8, 1, 0
        ]);
        let pmm = r.length >= 36 ? r.slice(20, 36) : null;
        return [this.idm, pmm];
    }
    async readWithoutEncryption(serviceCode, addr) {
        let r = await this.sendCommand(this.CMD_READ_WO_ENCRYPTION, [
            1, serviceCode & 0xff, serviceCode >> 8, 1, 0x80, addr
        ]);
        if (r.length < 26 || r.slice(20, 22) != '00') // StatusFlag1 != STA1_NORMAL
            return null;
        else
            return r.slice(26);
    }
}

Felica.prototype.CMD_POLLING = 0x00;
Felica.prototype.RSP_POLLING = 0x01;
Felica.prototype.CMD_READ_WO_ENCRYPTION = 0x06;
Felica.prototype.RSP_READ_WO_ENCRYPTION = 0x07;
