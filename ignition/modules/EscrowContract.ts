import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MicjohnModule = buildModule("MicjohnModule", (m) => {

    const escrow = m.contract("EscrowContract");

    return { escrow };
});

export default MicjohnModule;