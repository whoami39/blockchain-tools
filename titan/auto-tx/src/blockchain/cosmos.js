
// Telegram: https://t.me/blockchain_minter

const { SigningStargateClient, StargateClient, GasPrice } = require("@cosmjs/stargate");
const { DirectSecp256k1HdWallet } = require("@cosmjs/proto-signing");
const config = require('../config');

async function getWalletBalance(mnemonic) {
    const wallet = await DirectSecp256k1HdWallet.fromMnemonic(mnemonic, {
        prefix: config.chainConfig.prefix,
    });

    const [account] = await wallet.getAccounts();
    const address = account.address;

    const client = await StargateClient.connect(config.chainConfig.rpc);
    const balance = await client.getAllBalances(address);

    return { address, balance };
}

async function getAllWalletBalances() {
    const mnemonics = getAllMnemonics();
    const balances = [];
    for (const mnemonic of mnemonics) {
        const walletBalance = await getWalletBalance(mnemonic);
        balances.push(walletBalance);
    }
    return balances;
}

function getAllMnemonics() {
    const mnemonicSet = new Set();
    if (process.env[`MNEMONIC`]) {
        mnemonicSet.add(process.env[`MNEMONIC`]);
    }
    for (let i = 1; process.env[`MNEMONIC_${i}`]; i++) {
        mnemonicSet.add(process.env[`MNEMONIC_${i}`]);
    }
    return Array.from(mnemonicSet);
}
async function randomTransferBetweenWallets(amount) {
    const mnemonics = getAllMnemonics();
    if (mnemonics.length < 2) {
        throw new Error("至少需要两个不同的钱包助记词");
    }

    // 随机排序助记词数组
    const shuffledMnemonics = mnemonics.sort(() => 0.5 - Math.random());

    let senderWallet, recipientWallet;

    // 选择发送方钱包（余额必须足够）
    for (const mnemonic of shuffledMnemonics) {
        const { address, balance } = await getWalletBalance(mnemonic);
        const sufficientBalance = balance.find(b => 
            b.denom === config.chainConfig.denom && 
            BigInt(b.amount) >= BigInt(amount)
        );

        if (sufficientBalance) {
            senderWallet = { mnemonic, address };
            break;
        }
    }

    if (!senderWallet) {
        throw new Error("没有找到余额足够的钱包");
    }

    // 选择接收方钱包（不能是发送方）
    const recipientMnemonic = shuffledMnemonics.find(m => m !== senderWallet.mnemonic);
    if (!recipientMnemonic) {
        throw new Error("无法找到合适的接收方钱包");
    }

    const recipientWalletObj = await DirectSecp256k1HdWallet.fromMnemonic(recipientMnemonic, {
        prefix: config.chainConfig.prefix,
    });
    const [recipientAccount] = await recipientWalletObj.getAccounts();
    recipientWallet = recipientAccount.address;

    // 执行转账
    try {
        const wallet = await DirectSecp256k1HdWallet.fromMnemonic(senderWallet.mnemonic, {
            prefix: config.chainConfig.prefix,
        });

        const client = await SigningStargateClient.connectWithSigner(
            config.chainConfig.rpc,
            wallet,
            { gasPrice: GasPrice.fromString(config.chainConfig.gasPrice) }
        );

        const transferAmount = {
            denom: config.chainConfig.denom,
            amount: amount,
        };

        const result = await client.sendTokens(
            senderWallet.address,
            recipientWallet,
            [transferAmount],
            "auto",
            "Random transfer between wallets"
        );

        return {
            success: true,
            txHash: result.transactionHash,
            sender: senderWallet.address,
            recipient: recipientWallet,
            amount: amount
        };
    } catch (error) {
        console.error(`转账失败: ${error.message}`);
        return {
            success: false,
            error: error.message
        };
    }
}

module.exports = { 
    randomTransferBetweenWallets,
    getAllWalletBalances
};
