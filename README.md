# DFM Block Pro

**三角洲行动（Delta Force Mobile）恶意文件 & 坐标加密阻断模块**

专为一加 Ace 6 + KernelSU 环境私人定制。

---

## 功能

- 自动监控并清理游戏目录下与反作弊、坐标加密、遥测上报相关的文件
- 阻断常见腾讯游戏安全 / ACE / 上报域名（hosts）
- 游戏运行时锁定高风险目录写权限
- 清理 `/data/local/tmp` 中与应用列表、游戏相关的临时文件
- 开机自启动（KernelSU / Magisk 模块）

## 支持游戏

- 包名：`com.tencent.tmgp.dfm`（三角洲行动 国服）

## 安装方法

1. 下载最新 `DFM_Block_Pro_Ace6_v2.zip`
2. 使用 **KernelSU** 或 **Magisk** 刷入模块
3. 重启手机
4. 模块会自动在后台运行

## 控制命令

刷入后可在终端使用：

```bash
dfmblock log      # 查看最近日志
dfmblock status   # 查看运行状态# DFM