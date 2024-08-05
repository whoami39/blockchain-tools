module.exports = {
    baseInterval: process.env.TX_BASE_INTERVAL,
    maxAdditionalInterval: process.env.TX_MAX_ADDITIONAL_INTERVAL,
    minAmount: parseInt(process.env.TX_MIN_AMOUNT),
    maxAmount: parseInt(process.env.TX_MAX_AMOUNT),
};
