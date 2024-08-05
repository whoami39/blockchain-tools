# Titan Testnet

>【2024-07-07】当前该项目正在进行第三轮测试

>【2024-07-15】社区空投任务已经结束

## 相关链接

1. ~~空投任务 ( [https://titannet.io/airdrops](https://titannet.io/airdrops/?inviteCode=cppae4363k8c73cdd530) )~~ 已结束

2. 节点挖矿 ( [https://test1.titannet.io](https://test1.titannet.io/intiveRegister?code=jARato) )

3. 质押挖矿 ( https://staking.titannet.io )

## 相关工具

### 容器化部署 ( [deploy](./deploy) )

- [x] 支持多个节点，一个 IP 最多 5 个节点）

### 自动化领水 ( [faucet](./faucet) )

> 领的水用于进行质押挖矿测试

- [x] 自动领水：到时间自动发送消息领水，支持多个 DC 账号并行
- [x] 反作弊检查

### 模拟交易系统 | Trading Simulation System  ( [auto-tx](./auto-tx/) )

> 为钱包增加更多测试币交易记录

- [x] 支持 Titan，多个钱包随机互相转帐，程序自动维持各钱包余额动态平衡
- [x] 可设置：每次转账间隔时间范围、每次转账金额范围
- [x] 容器化部署
