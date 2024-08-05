module.exports = {
    prefix: process.env.CHAIN_PREFIX,
    denom: process.env.CHAIN_DENOM,
    rpc: process.env.CHAIN_RPC,
    gasPrice: process.env.CHAIN_GAS_PRICE,
    coinDecimals: parseInt(process.env.COIN_DECIMALS)
};
