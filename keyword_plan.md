# Slime Keyboard Escape 关键词清理、意图分组与 URL 结构规划

这份文档是基于您收集的上百条原始关键词，严格按照**“清理不相关词 -> 同义表达合并 -> 搜索意图分组 -> 匹配页面类型 -> 确定开发优先级”**的方法整理出的最终标准词表。

---

## 一、 关键词清洗与降噪说明

在整理过程中，我们将原始词表进行了三类处理：
1. **保留并合并同义词**：例如将 `slime keyboard escape unblocked`、`slime keyboard escape github`、`slime keyboard escape chromebook` 等统一归入 **Unblocked 场景页**。
2. **重构为功能/内容点**：例如将 `slime keyboard escape key not working`（按键失效）、`how to play`（怎么玩）归入 **玩法指南与 FAQ**。
3. **标记过滤（垃圾/噪声词）**：
   - 硬件/设备干扰：`slime keyboard escape desk`（桌面搭配）
   - 影视/节目干扰：`slime keyboard escape the night`（娱乐节目）
   - 开发者底层代码：`slime keyboard escape java / javascript / json`
   - 不匹配的操作包：纯 Roblox 外部脚本挂（网页端无法使用）

---

## 二、 按哥飞 SEO 教程【搜索意图分组】模型与 URL 架构映射

参照哥飞教程中将“AI图片工具”拆解为（生成类 / 修复类 / 风格转换类 / 场景类）的思路，我们把小游戏 **`Slime Keyboard Escape`** 的所有搜索意图拆解为以下 **5 大功能大类**。

绝对不把所有词塞在一个页面里，而是：**“首页负责总需求与入口引导，专题中心负责分门别类，具体页面负责满足单一明确需求”**：

---

### 1. 第一类：直接游玩与入口类 (Direct Play & Access Intent)
* **包含关键词**：`slime keyboard escape`, `play online`, `free`, `game`, `pc`, `online`
* **用户真实需求**：想打开网页即玩，寻求 100% 免费、无需下载安装的在线原生游玩入口。
* **分工与 URL**：**首页 / 主游玩落地页 (`/` 或 `/play.html`)**

### 2. 第二类：场景解封与渠道类 (Unblocked & School Access Intent)
* **包含关键词**：`unblocked`, `github`, `classroom 6x`, `unblocked 76/66`, `chromebook`
* **用户真实需求**：在学校/工作网防火墙受限，寻找专用的 Unblocked 解封节点或 Chromebook 优化版。
* **分工与 URL**：**Unblocked 解封专题页 (`/unblocked.html`)**

### 3. 第三类：攻略求解与故障排查类 (Guide, Controls & FAQ Intent)
* **包含关键词**：`how to play`, `controls`, `walkthrough`, `key not working`, `instructions`
* **用户真实需求**：卡关求助通关技巧、查询 WASD / 键盘控制映射，或排查游戏按键无响应问题。
* **分工与 URL**：**攻略指南与 FAQ 模块 (`/guides/how-to-play.html`, `/faq.html`)**

### 4. 第四类：代码、极速模式与平台对比类 (Codes, Speedrun & Platform Intent)
* **包含关键词**：`keyboard escape codes`, `1 speed`, `plus 1 speed`, `roblox keyboard escape`
* **用户真实需求**：寻找特权代码 (Codes) 或“1 Speed”极速挑战模式；以及搜 Roblox 版本想找网页免费版的用户。
* **分工与 URL**：**代码/模式与对比专题页 (`/codes.html`, `/modes/speed.html`, `/vs/roblox.html`)**

### 5. 第五类：同类题材与分类探索类 (Categories & Genre Intent)
* **包含关键词**：`Obby Games`, `Typing Games`, `Keyboard Games`, `slime escape game`
* **用户真实需求**：游玩完本游戏后，寻找 Obby (障碍跑酷)、Typing (键盘) 或 Slime 题材的同类小游戏。
* **分工与 URL**：**游戏分类中心页 (`/categories/obby-games.html`, `/categories/typing-games.html`)**

---

## 三、 搜索意图分组与 URL 页面映射总览

| 意图大类 (Intent Category) | 核心需求描述 | 拟对应页面 (Suggested URL) | 覆盖核心关键词例举 | 组优先级 |
| :--- | :--- | :--- | :--- | :--- |
| **第一类：直接游玩与入口** | 直接寻找游戏入口，想在 PC/手机在线即玩 | **首页 / 游玩页** (`/` 或 `/play.html`) | `slime keyboard escape`, `play online`, `free`, `game`, `pc` | 🔴 **P0** (必做) |
| **第二类：场景解封与渠道** | 在学校/工作网搜解封版本，用 Chromebook/GitHub 游玩 | **Unblocked 专题页** (`/unblocked.html`) | `unblocked`, `github`, `classroom 6x`, `unblocked 76/66`, `chromebook` | 🔴 **P0** (必做) |
| **第三类：攻略求解与排查** | 卡关、求助操作按键、按键没反应、了解基础规则 | **玩法攻略页** (`/guides/how-to-play.html`) | `how to play`, `controls`, `walkthrough`, `key not working`, `instructions` | 🟡 **P1** (第二批) |
| **第四类：代码与模式对比** | 寻找兑换码 (Codes)、1倍速 (1 Speed)、极速逃脱模式 | **代码与模式页** (`/codes.html` 或 `/modes/speed.html`) | `codes`, `1 speed`, `plus 1 speed keyboard escape codes`, `speedrun` | 🟡 **P1** (第二批) |
| **第五类：同类题材与分类** | 喜欢 Obby (障碍跑酷)、Typing (键盘) 或 Slime 题材小游戏 | **分类聚合页** (`/categories/obby-games.html`) | `Obby Games`, `Typing Games`, `Keyboard Games`, `slime escape game` | 🟢 **P2** (后续扩建) |


---

## 三、 清理后的完整关键词清单表 (支持直接导出至 Excel)

| 关键词 (Keyword) | 搜索量/热度 (Volume) | 搜索意图 (Search Intent) | 意图分组 (Group) | 拟对应页面类型 (Page Type & URL) | 优先级 | 备注与处理策略 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`slime keyboard escape`** | 飙升词 (+5000%) | 品牌主词，直接寻找游戏入口 | Group 1: 品牌与游玩 | 首页 (`/`) | 🔴 P0 | 核心品牌落地页，承接全站主流量 |
| **`slime keyboard escape online`** | 高 | 寻求网页免下载即玩入口 | Group 1: 品牌与游玩 | 首页 (`/`) | 🔴 P0 | 首页 Header 突出 "Play Online Free" |
| **`slime keyboard escape free`** | 高 | 寻求免费在线游玩 | Group 1: 品牌与游玩 | 首页 (`/`) | 🔴 P0 | 标注 100% Free, No Purchase |
| **`slime keyboard escape game`** | 高 | 带 Game 后缀的标准游玩词 | Group 1: 品牌与游玩 | 首页 (`/`) | 🔴 P0 | 首页 `<title>` 覆盖 |
| **`slime keyboard escape pc`** | 中-高 | 寻找电脑端 (WASD/方向键) 游玩 | Group 1: 品牌与游玩 | 首页 (`/`) | 🔴 P0 | 突出 PC 键盘原汁原味操控 |
| **`slime keyboard escape download`** | 中 | 寻找下载/离线安装包 | Group 1: 品牌与游玩 | 首页 / `/download.html` | 🟡 P1 | 页面说明“网页直接玩，无需下载”，并提供 PWA/离线保存指引 |
| **`slime keyboard escape unblocked`** | 飙升词 (+5000%) | 学校/工作网突破限制游玩 | Group 2: 解封与设备 | Unblocked 专题页 (`/unblocked.html`) | 🔴 P0 | **核心爆款词**！独立静态 HTML 保证高可访问性 |
| **`slime keyboard escape github`** | 高 | 寻找托管在 GitHub Pages 的解封镜像 | Group 2: 解封与设备 | Unblocked 专题页 (`/unblocked.html`) | 🔴 P0 | 页面内增加 GitHub 镜像/轻量版本说明 |
| **`slime keyboard escape classroom 6x`** | 高 | 学校热门解封站 (Classroom 6x) 搜索 | Group 2: 解封与设备 | Unblocked 专题页 (`/unblocked.html`) | 🔴 P0 | Title/H2 标注 "Classroom 6x Alternative" |
| **`slime keyboard escape unblocked 76`** | 高 | 搜 Unblocked Games 76 节点 | Group 2: 解封与设备 | Unblocked 专题页 (`/unblocked.html`) | 🔴 P0 | H2 融入 Unblocked 76/66 关键词 |
| **`slime keyboard escape chromebook`** | 中-高 | 美国学生用 Chromebook 专属搜索 | Group 2: 解封与设备 | Unblocked 专题页 (`/unblocked.html`) | 🔴 P0 | 强调 100% Chromebook Smooth & Fast |
| **`slime keyboard escape how to play`** | 中 | 新手询问怎么玩/快捷键 | Group 3: 攻略与 FAQ | 玩法攻略页 (`/guides/how-to-play.html`) | 🟡 P1 | 制作图文 WASD + Space 按键说明 |
| **`slime keyboard escape controls`** | 中 | 寻找控制键位与手柄映射 | Group 3: 攻略与 FAQ | 玩法攻略页 (`/guides/how-to-play.html`) | 🟡 P1 | 详细列出键盘/触屏/手柄键位表 |
| **`slime keyboard escape key not working`** | 中 | 遇到按键无响应/卡顿问题 | Group 3: 攻略与 FAQ | FAQ / 帮助模块 (`/faq.html`) | 🟡 P1 | 增加 FAQ 结构化数据 (JSON-LD)，解答焦点切换与按键冲突 |
| **`slime keyboard escape walkthrough`** | 中 | 查找通关攻略/难关解法 | Group 3: 攻略与 FAQ | 玩法攻略页 (`/guides/walkthrough.html`) | 🟡 P1 | 提供各关卡陷阱避开技巧与通关视频 |
| **`keyboard escape codes`** | 高 (Rising) | 寻找礼包码/代码 (Codes) | Group 4: 代码与模式 | 代码与礼包页 (`/codes.html`) | 🟡 P1 | Roblox 版极火热的搜索，可借势吸引流量并解答 |
| **`1 speed slime keyboard escape`** | 高 (Rising) | 寻求 1 倍速/极速挑战模式 | Group 4: 代码与模式 | 模式与特色页 (`/modes/speed.html`) | 🟡 P1 | 介绍 1-Speed 机制，提供倍速玩法 |
| **`roblox keyboard escape`** | 高 | 寻找 Roblox 平台上的同名地图 | Group 4: 代码与模式 | 对比与落地页 (`/vs/roblox.html`) | 🟡 P1 | 标明“网页直接玩，无需安装 Roblox 客户端”借势截流 |
| **`Obby Games`** | 极高 (Poki大类) | 寻找障碍跑酷/Obby跳跃小游戏 | Group 5: 分类与同类 | 分类页 (`/categories/obby-games.html`) | 🟢 P2 | 将 Slime 避障归入 Obby 热门大类 |
| **`Typing Games`** | 极高 (Poki大类) | 寻找键盘打字/操控类游戏 | Group 5: 分类与同类 | 分类页 (`/categories/typing-games.html`) | 🟢 P2 | 建键盘小游戏聚合专题 |
| **`slime escape game`** | 中 | 泛 Slime 逃脱类游戏搜索 | Group 5: 分类与同类 | 分类页 (`/categories/slime-games.html`) | 🟢 P2 | 聚合其他 Slime 题材小游戏推荐 |

---

## 四、 过滤清理出的【垃圾/干扰词】清单（暂不制作页面）

| 过滤关键词 (Filtered Keyword) | 过滤原因 (Reason for Filtering) |
| :--- | :--- |
| `slime keyboard escape desk` | 属于硬件桌面搭配/办公装备搜索，与小游戏无关 |
| `slime keyboard escape the night` | 匹配到某娱乐/影视节目名称，属于同名噪声词 |
| `slime keyboard escape java / javascript / json` | 属于开发者搜索源码/底层引擎，非玩家游戏意图 |
| `slime keyboard escape hack / script` (Roblox脚本) | 纯第三方平台外挂脚本，无法在网页原生游戏使用且容易带来安全隐患 |
| `slime keyboard escape instructions pdf` | 极冷门且网页游戏不需要 PDF 手册，合并入网页 Guide 即可 |
