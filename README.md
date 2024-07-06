# Blockchain Tools

> 你可以 *[加入 Telegram](https://t.me/+ZOQ2jcLKI3hkNjFl)* 获取更多信息

---

## Titan Testnet

>【2024-07-07】当前该项目正在进行第三轮测试

### 相关链接

1. 空投任务 ( [https://titannet.io/airdrops](https://titannet.io/airdrops/?inviteCode=cppae4363k8c73cdd530) )

2. 节点挖矿 ( [https://test1.titannet.io](https://test1.titannet.io/intiveRegister?code=jARato) )

3. 质押挖矿 ( https://staking.titannet.io )

### 相关工具

#### 容器化部署 ( [titan/deploy](./titan/deploy) )

- [x] 支持多个节点，一个 IP 最多 5 个节点）

#### 自动化领水 ( [titan/faucet](./titan/faucet) )

> 领的水用于进行质押挖矿测试

- [x] 自动领水：到时间自动发送消息领水，支持多个 DC 账号并行
- [x] 反作弊检查：在基础间隔时间（2 小时）上可增加随机时间，防止领水时间存在规律

#### 模拟交易系统

> 为钱包增加更多相关的测试交易记录

- [ ] 多个钱包随机互相转帐
- [ ] 自动领水，防止因 Gas 不足导致模拟交易停止运行，维持各钱包余额动态平衡
