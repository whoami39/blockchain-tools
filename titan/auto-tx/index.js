
// Telegram: https://t.me/blockchain_minter

require('dotenv').config();
const { txConfig } = require('./src/config');
const { randomTransferBetweenWallets } = require('./src/blockchain/cosmos');

function startPeriodicRandomTransfers(baseIntervalMinutes, maxAdditionalMinutes, minAmountInteger, maxAmountInteger) {
    console.log("\n让我们开始吧 | Let's get started\n");
    console.log("你可以访问: https://t.me/blockchain_minter 获得帮助 | You can visit: https://t.me/blockchain_minter for help\n\n");

    executeRandomTransfer(minAmountInteger, maxAmountInteger);
    scheduleNextTransfer(baseIntervalMinutes, maxAdditionalMinutes, minAmountInteger, maxAmountInteger);
}

function scheduleNextTransfer(baseIntervalMinutes, maxAdditionalMinutes, minAmountInteger, maxAmountInteger) {
    const baseMs = baseIntervalMinutes * 60 * 1000;
    const additionalMs = Math.floor(Math.random() * maxAdditionalMinutes * 60 * 1000);
    const totalIntervalMs = baseMs + additionalMs;

    const nextTransferDate = new Date(Date.now() + totalIntervalMs);
    console.log(`开始进行转账，下一次转账计划在 [${nextTransferDate.toLocaleString()}] 执行 | Next transfer scheduled at [${nextTransferDate.toLocaleString()}]`);

    setTimeout(() => {
        executeRandomTransfer(minAmountInteger, maxAmountInteger);
        scheduleNextTransfer(baseIntervalMinutes, maxAdditionalMinutes, minAmountInteger, maxAmountInteger);
    }, totalIntervalMs);
}

function getRandomAmount(min, max) {
    const randomInteger = Math.floor(Math.random() * (max - min + 1)) + min;
    return (BigInt(randomInteger) * BigInt(1000000)).toString();
}

async function executeRandomTransfer(minAmountInteger, maxAmountInteger) {
    const transferAmount = getRandomAmount(minAmountInteger, maxAmountInteger);
    const transferAmountInteger = BigInt(transferAmount) / BigInt(1000000);

    const currentTime = new Date().toLocaleString();
    try {
        const result = await randomTransferBetweenWallets(transferAmount);
        console.log(`本次转账成功：${transferAmountInteger} TTNT | Transfer successful: ${transferAmountInteger} TTNT`);
        if (result.success) {
            console.log(`- 发送方: ${result.sender} | Sender: ${result.sender}`);
            console.log(`- 接收方: ${result.recipient} | Recipient: ${result.recipient}`);
            console.log(`- 交易哈希: ${result.txHash} | Transaction hash: ${result.txHash}`);
            console.log(`- 时间: ${currentTime} | Time: ${currentTime}\n`);
        } else {
            console.error(`转账失败: ${result.error} | Transfer failed: ${result.error}`);
        }
    } catch (error) {
        console.error(`执行转账时发生错误: ${error.message} | Error occurred while executing transfer: ${error.message}`);
    }
}

startPeriodicRandomTransfers(txConfig.baseInterval, txConfig.maxAdditionalInterval, txConfig.minAmount, txConfig.maxAmount);
