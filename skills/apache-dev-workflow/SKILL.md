---
name: apache-dev-workflow
description: >-
  ASF-generic end-to-end contribution workflow orchestration: backlog and
  issue selection with profile matching, branch setup, local verification,
  fork-side CI staging, upstream PR preparation, review iteration, and
  merge/withdraw decisions. Use ONLY when BOTH hold: (1) the repo is Apache
  (a checkout or fork of a github.com/apache project) and (2) the user
  wants to start, continue, or orchestrate development end to end — pick or
  get a recommended issue, claim it, run the right local tests, stage the
  change on the fork and watch CI, prepare the upstream PR, absorb reviewer
  feedback, or review PR status and decide keep/withdraw, even indirectly
  ("找个 issue 开始做", "今晚两小时有什么小任务", "CI 跑完告诉我", "我的 PR
  都什么状态了"). Loads or mines the per-repo rule pack and dispatches
  stages by its axes. Enforces approval gating on every git/gh write, no
  upstream PR without an issue, never push the official remote.
when_to_use: >-
  Also for continuing interrupted work (read docs/tasks state first),
  mobile self-review loops, and cross-session PR status tracking; indirect
  phrases include "看看 reviewer 说了什么", "这个先不做了". Do NOT trigger
  for single commit/PR mechanics without workflow intent (apache-commit-pr),
  plain git questions, non-Apache repositories, or fork/branch syncing
  (apache-sync-fork).
---

# apache-dev-workflow — Apache 通用端到端贡献工作流（七阶段编排）

> **定位**：个人级通用 skill。本 skill 管**端到端任务编排**（七阶段骨架 + 批准门控 +
> 规则包轴分派 + backlog 画像匹配与移动自审闭环）；**commit/PR 时点的规范细则**（标题
> 模板 / PR 模板段 / 门禁清单 / 证据链卡 / 规范自检的执行形态）**声明遵循同族
> `apache-commit-pr`**——两者共读同一规则包（`.zcode/rules/<project>.md`，单一事实
> 来源）、共持同一 [USER] 政策层与同一内联挖掘程序（同文双载），同意图双触发经
> Step 0 会话内去重收敛，谁先触发行为一致；fork↔upstream 分支同步归 `apache-sync-fork`
> （其同步集自包含，不读本套件规则包）。
> **一切仓库特定值（标题格式 / 默认分支 / 门禁命令 / 模板段 / label 词汇 / 分支命名 /
> 渠道地址 / CI 载体 / stale 阈值……）来自规则包；本正文不含任何仓库规则性事实。**
> 阶段存在性与门控固定，机制处处按规则包轴分派（六轴 + 4 维度 + 各节）。
> **标注体系**：[MECH] = GitHub/gh 引擎机制（与仓库无关）；[ASF] = Apache 软件基金会
> 全项目政策；[USER] = 用户协作约定（user rule, stricter than community norms）。
> **反闭门造车原则**（用户裁决 2026-10-13）：写死的仅限"非常确定"的三级内容——引擎
> 机制 / 基金会政策 / 用户政策；一切项目事实优先在运行时从已 clone 的仓库现读（项目
> 文档 / git 变更摘要与记录 / CI 配置），cache 即现读结果的持久化，miss 当场派生。
> **安装形态**：本文件 → `~/.zcode/skills/apache-dev-workflow/SKILL.md`；种子模板 →
> 同目录 `templates/rule-pack-template.md`（内联挖掘程序落盘产物的母版）。

## Step 0 — Load the repository rule pack（MANDATORY — before any other step）

**会话内去重**：本会话已加载过本仓规则包或已有挖掘结果 → 直接复用，不重复读取 /
挖掘 / 二次请批（双 skill 触发的动作收敛）。

0. **让渡前置检查（先于一切读取）**：若本会话的技能发现列表中存在本仓库自包含的
   同意图项目级 skill（迁移前旧形态），**完全让渡**——不读包、不挖掘、不 bootstrap，
   由该旧 skill 主导全部行为。判定基准 = **技能发现列表**（归档目录不在发现路径内，
   故旧 skill 归档后让渡自动解除）。
1. **上游识别链**（[MECH] 级程序——识别是程序不是常量；按 URL，绝不按远端名）：
   a. `git remote -v`：存在指向 `github.com/apache/<project>` 的远端 → 官方远端，
      `<project>` 即规则包键（快路径，覆盖主场景）。
   b. 未命中且 origin 是 GitHub 仓 → **fork 血缘 API（权威兜底，匿名可用）**：
      `GET api.github.com/repos/<owner>/<repo>` → `.fork=true` 时官方仓库 =
      `.source.full_name`（**嵌套 fork 取 source 而非 parent**——source 是 fork 网络
      的根）；本地已有指向它的远端则用之，没有则告知用户可自行 `git remote add`
      （不自动添加）。
   c. **归属判断（独立于识别）**：官方仓库属 `apache/` 组织**或**仓库含 `.asf.yaml`
      → ASF 项目，启用内核合规清单（ALv2/ICLA/PR-first）；非 apache 组织 → **同一
      骨架照用，ASF 专属合规项按 N/A 处理**并声明哪些规范不适用（不装死不硬拒；
      此为显式斜杠调用时的正文级降级路径，不在触发域内）。
   d. 均失败（非 GitHub 托管 / 血缘缺失）→ 询问用户，不猜。
2. **立即完整读取** `<repo-root>/.zcode/rules/<project>.md`（完整读取，不跳读）：
   **G 层** = 通用内核规则快照（抗跳读冗余——skill 正文永远权威）；**P 层** = 项目
   CI/CD 规则缓存。**P-cache 命中且未失效 → 直接使用，无须再次采集**，并呈报一行
   来源（如 `cache 命中 · verified <日期> · 来源 .zcode/rules/<project>.md`）。
3. **包/缓存缺失**（新仓、首次执行、fresh clone——**正常态而非错误**）：先查个人母本
   `~/.zcode/rules/<project>.md` 恢复（≤1 次批准，≤5 分钟）；仍缺失则**当场执行本文
   「内联挖掘程序」**（只读、分钟级）：结果直接用于当前任务，并经用户批准写入 cache
   供下次直用——首次执行即"采集并缓存"的过程，任务不被阻断。用户拒绝落 cache =
   本次仅使用不落盘，下次 miss 再问（不设持久抑制状态）。**DO NOT guess or borrow
   another repository's rules — not even partially**（禁止的是"不挖掘就猜/借"；挖掘
   本身就是反猜测机制）；挖掘仍定不了的字段 → 通用默认 + 询问用户。
4. **cache 失效判定**（时间 + 事件双触发；**判定前先 `git fetch <upstream> --prune`**
   ——fetch 属免批准的只读操作）：`verified` 头超 90 天；或 CI 工件（workflows / lint
   配置 / 模板 / .asf.yaml）自 `verified` 后有变更 → 包级重挖（纪律见「内联挖掘程序
   ·失效重挖」）。
5. **冲突裁决序**：**[USER] 政策层（不可被覆盖，仅用户显式豁免可解除）> P 层项目事实
   > skill 正文（非 [USER] 内核）> G 层快照**。P 层对 [USER] 政策只能记录偏差事实并
   呈报用户（例："社区近期 merged PR 样本多数不用 close 关键字"是偏差事实，不得据此
   推翻用户"无 issue 不开 PR"政策），不得覆盖；upstream 自己的 AGENTS.md / 模板与包
   冲突时同样呈报用户裁决，**禁止静默择一**。
6. **schema 降级**：包的 schema-version 不认识 = 按"缺失"降级处理（走第 3 条），结果
   仅内存使用，**不覆写原包**，并呈报用户（防跨机版本乒乓）。

## [USER] 政策操作层（阶段门共享约定；与 apache-commit-pr 同源）

1. **批准门控（字面全拦，2026-10-13 仲裁）**：一切 git/gh 写操作须经当会话用户明确
   批准——本地 commit、push、PR/issue/评论写（含认领、ping、close、请求批准评论）、
   CI rerun、规则包 cache 落盘、远端分支删除，全部在内。批准的形态 = 用户当会话的
   **明确指令**或对**批准卡的明确答复**；指令覆盖范围以字面为准，含混时收窄解释
   （如"提交一下"默认只覆盖本地 commit，push/PR 另出批准卡）。
   - **批准卡五要素**（全仓统一模板）：① 待批**命令原文逐字**；② **风险**一句话；
     ③ **任务号**（有 issue = `issue #N`；无 issue 的运维场景 = 任务日志条目 ID，如
     `<分支或主题>-<日期>`）；④ **替代选项**（≥2 个）；⑤ **30min 未批 → park**
     （挂起 + 摘要保留，随时恢复，不自动重试）。
   - **本轮套餐卡**（本 skill 常用卡形）：一轮多步写操作（如 commit + push + 指定
     评论）可逐条列卡打包呈批；**远端写永远在卡上单列确认**；随卡材料 = diff 概要 /
     文件清单 + 本地门禁已跑结果。
   - **减压阀 = "这轮都批"**（对话化的会话作用域范围授权，如用户分条指令"2、3 条
     改了推上去"）：授权范围内不再逐条请批，但每步远端写逐条留痕任务日志；**远端写
     永不进永久免批**；跨轮新写操作另卡。
   - 批准门只认会话不认来路：经用户配置的 Bot Channel（不写死信道名）到达的批准 =
     会话内批准；执行者恒为桌面会话（Bot Channel 是其远程界面；桌面 app 在线是前提，
     见诚实限制节）。
   - **事件等待 vs 批准超时**：等 CI 完成 / 等 review 到达 = 事件挂起，**无超时**
     （会话内轮询，命中后即时推送草稿呈递——不执行写）；等**批准**才有 30min park。
   - **免批准只读集合**：`git fetch <upstream> --prune`、gh 读取类命令、匿名 API、
     「内联挖掘程序」的全部输入操作。
2. **无 issue 不开 PR**（用户裁决 2026-10-13：**完全不豁免**）：一切 PR 从 issue 起步
   ——含 typo、doc、follow-up；follow-up 场景原 issue 已关闭时，新建或 reopen issue
   引用原 PR 起步。**零例外**。关联通道由规则包 issue-link-channel 轴分派（见阶段 5）。
3. **AI 披露**（用户裁决 2026-10-13）：PR 正文自愿附加 `Assisted-by: <模型名称:版本号>`
   （如 `Assisted-by: ZCode:GLM-5.3`）。规则包 template 节记载项目模板有无 AI 段：
   有则填入该段，无则自愿附加（落点见阶段 5 组装）。

## 七阶段骨架（阶段存在性与门控固定；机制按规则包轴分派）

**总则**：每阶段动手前对照规则包 **§guardrails**（项目灾难级护栏，置顶节）复核一次；
每次阶段转移**即时写回任务日志**（纪律见「状态与跨会话」）。门控（何者需批准卡）如
下文固定；命令值、词汇、时长、渠道等一切项目值一律"读包"。

### 阶段 0 — 一次性设置

- **fork 准备**：无个人 fork → 提示用户 fork（fork 创建属远端写，走批准门或用户自行
  操作）；已有 → 确认本地远端布局（origin=fork、官方远端=Step 0 识别产物；缺官方
  远端时告知用户可自行 `git remote add`，不自动添加）。
- **fork Actions 启用**：GitHub UI 手工操作（Settings → Actions），git/gh 无法代办。
  **ci-carrier=push-direct 时必须**——不启用 = push 不触发任何 CI，阶段 4 失去全部
  判据；其他载体值按包 §ci 记载的启动礼仪办理。
- **一次性记账**：完成后写入任务日志；后续会话不再重复询问（环境重建除外）。

### 阶段 0.5 — backlog 画像匹配（轻量，不做重状态机）

1. **先读任务日志**：`docs/tasks/backlog.md`——当前任务与所处阶段（有在途任务 →
   先呈报状态再议新任务，避免并行开挖）；及其头部**用户偏好节**（**可用时间 / 类型
   倾向 / 模块熟悉度**三项）。偏好节缺失 = 首次使用：从对话提取（如"今晚约 2 小时、
   想修 bug、熟悉某模块"）记录成节；用户陈述变化即对话化更新（零额外仪式）。
2. **候选池刷新**（只读免批）：筛选面**只来自规则包 §filter**（issue 模板形态 +
   label/search 词汇表；**label 词汇必须来自本仓一手清单，禁止跨仓继承**——他仓
   词汇在本仓查空后断言"没有可用 issue"是硬失败）。池过期（拉取时间戳老化，或用户
   要求换切片）→ 重新拉取，记录所用 filter + 时间戳写回 backlog。
3. **逐项画像**（issue 特征，信号全部来自 API 字段）：
   - **颗粒度估计**：body 长度 / 模板段完整度 / 涉及模块数 → 粗估工时量级；
   - **类型**：bug / feature / doc / 依赖升级……按 §filter 词汇归类；
   - **活跃度**：updated_at 距今 / 评论信号 / maintainer 活动痕迹；
   - **撞车三查**（推荐与认领前必做——池只是快照）：① state=open；② 无 assignee；
     ③ 无在途 linked PR（`gh issue view <N> --json state,assignees,comments` + issue
     timeline API 查 linked PR——open linked PR=有人在做→跳过；closed-unmerged=有
     前人尝试→呈报用户决定是否接手）。
4. **产出**：Top 2-3 推荐 + 每项**"为什么适合你"**（时间画像 × 类型倾向 × 模块熟悉度
   × 撞车风险）+ **时间盒过滤**（超出可用时间的颗粒度降级或排除）；**只呈现分级
   结果，不倾倒原始列表**；写回 backlog 候选池。
5. **用户自带想法**（[USER]"无 issue 不开 PR"的上游面）：用户带来 substantive 想法
   而非池内 issue → 先按阶段 1"先搜后建"草拟 issue 请确认，再动工。
6. **认领（本阶段唯一批准卡）**：用户选定后复核撞车三查 → 草拟认领评论（"taking
   this"类措辞；非 committer 不能 self-assign，[ASF] 默认礼仪）→ 批准卡（以用户身份
   在官方仓公开发表评论 = 进入社区视野的认领承诺）。

### 阶段 1 — issue

1. **先搜后建**（[ASF] 默认礼仪）：`gh issue list -R <upstream> --state open
   --search "<关键词>"` 充分检索 → 命中即用既有 issue；确无 → 起新 issue（`gh issue
   create -R <upstream> --title ... --body-file <f>`；GitHub issue forms 无法被非交互
   填充——直接传 body 内容，[MECH]）。**建 issue = 公开写 → 批准卡**。
2. **提案先行（大变更不直接进阶段 2）**：架构级 / 影响面大 / 新公共 API 类变更——按
   规则包 §routing 走项目的提案/讨论通道（如邮件列表 [DISCUSS] 线程、FLIP/KPIP 类
   提案流程、讨论区——通道形态与地址读包 §routing，标注"未证实"的渠道用前呈报），
   草拟提案请用户过目后发出（批准卡）；**绿灯信号**（assignee 指向 / maintainer +1 /
   提案被接纳）到达后才进阶段 2。
3. **认领**：阶段 0.5 第 6 步未行使则此处行使（同批准卡路径）。
4. **分流**：纯提问 → 包 §routing 问答渠道，不占 issue；安全问题 → 「安全漏洞改道」
   硬分支，永不占公开 issue。

### 阶段 2 — 分支

```
git fetch <upstream> <默认分支>          # 只读免批
git checkout -b <branch-name> <upstream>/<默认分支>
```

- **基点** = 规则包轴1 default-branch（包内记载双确认来源；**不猜**——基点错 = PR
  开在错分支上）。backport / 修复进维护线场景：目标分支按包 target-branch-backport
  维度与轴2 release-branch-pattern 分派；包值 unknown → 呈报用户裁决，不引用他仓
  先例。
- **命名**：读包 §misc 分支命名条目；无成文惯例（unknown）→ 短横线描述性命名即可，
  不发明仪式。

### 阶段 3 — 本地验证

1. **检查链**：规则包 §pre-commit 逐条（门禁命令 + 仓库专属清单，各带 CI 工件出处）
   本地实跑；**未跑项 = 差距项，不得标绿**。
2. **目标模块测试**：按改动面选包 §local 的定向/全量命令与 profile；**本地过 = 必要
   非充分**——CI 矩阵维度（JDK/OS/引擎等，读包 §local 列出的矩阵）本地通常只覆盖
   子集，"本地过 ≠ CI 必绿"。
3. **修复循环在本阶段内闭合**：改码 → 重跑检查链 → 全绿（或差距显式呈报）才进
   阶段 4。本地构建 / 格式化 / 测试不入批准门。

### 阶段 4 — fork 暂存 + CI + 自审

1. **push = 批准门（本轮套餐卡）**：
   ```
   [批准卡 · issue #N · 本轮套餐] 待批命令（原文，逐条）:
     1) git commit -m "<标题——格式读包 §title；人工永不写 (#N) 尾缀>"
     2) git push -u origin <branch>                 ← 远端写，单列确认
   风险: 1) 本地提交（可 reset 撤销，不触远端）；2) 推送到个人 fork（不触碰 upstream）
   任务号: issue #N
   随卡呈报: 待提交文件清单 + diff 概要；本地门禁已跑结果
   替代: a) 只 commit 不 push   b) 先看完整 diff   c) 补跑全量门禁后再呈
   30min 未批 → park（改动保留于工作树，不自动重试）
   ```
   批准本卡（或用户明示"这轮都批"）= 会话作用域授权，覆盖本轮列出的多步；跨轮新写
   另卡。commit 标题细则与证据链卡形态遵循 apache-commit-pr。
2. **CI 载体轴分派（轴5 ci-carrier）**：
   - **push-direct**：push 任意分支即触发完整 CI——`gh run list -R <fork> --branch
     <branch>` 监控、失败 `gh run view <run-id> --log-failed` 下钻（必要时
     `-j <job-id>`）；快门禁时长与常态墙钟读包 §ci；**绝不开 intra-fork PR**（此
     载体下错轨道 = 制造无 CI 价值且需手动清理的实体）。
   - **intra-fork-PR-only**：fork 侧 CI 的唯一触发器是 intra-fork PR——开
     `gh pr create -R <fork> --base <fork 默认分支> --head <branch>` 触发，
     `gh pr checks -R <fork>` 监控；**验证完必须关闭，绝不合并进 fork 默认分支**
     （fork 默认分支分叉 = 永久破坏 ff-only 再同步，[MECH]）；关闭该 PR = 远端写 →
     批准卡。
   - **upstream-pr**：CI 仅在 upstream PR 创建后运行——本阶段退化为"暂存完成 +
     提请进阶段 5"，CI 解读后移（五态框架不变）。
   - 轴值 unknown → 走内联挖掘程序判定，不猜。
3. **CI 五态解读报告**（每 job 一行，**job / 态 / 依据 / 行动**四列表 + 结论行；
   **无依据不得断言**）：
   - **真 bug**：失败定位到本次 diff 涉及的模块/测试 → 回阶段 3 修复循环；
   - **环境**：基础设施 / 网络 / 依赖拉取类失败 → 观察或（批准后）重跑；
   - **flaky**：判定程序弱，措辞降级——"**疑似 flaky → 批准 rerun 验证**"（rerun =
     写 → 批准卡，可入"这轮都批"）；
   - **未跑（首贡献 approve-label 门控）**：识别 waiting 状态 → 按包 §ci 记载的首
     贡献批准链解释解锁机制，草拟请求批准评论出卡——**勿误报为失败并返工**；
   - **规范门禁**（lint / license 类）：**不可 rerun 救** → 必须改代码/补头，回
     §pre-commit 检查链。
   已知基线噪音（包 §ci 记载的预期飘红类）对比排除，不当回归恐慌。结论行给出：
   你的问题 X 项 / 非你的 Y 项 / 流程性 Z 项。
4. **手机自审（载体按 ci-carrier 分派）**：intra-fork-PR-only = intra-fork PR（GitHub
   mobile 渲染 diff/CI/评论，一物三用：CI 验证 + 移动自审 + 修复跟踪线）；push-direct
   = 分支 diff（`gh pr diff` / compare 视图 / 分支 diff URL）。用户在载体上的评论 =
   一等用户输入。
5. **条件唤醒 = 会话内轮询**：进入本阶段时提议建立会话内轮询（约 30min 级）读 run /
   PR 状态（只读），CI 完成或评论到达 → 即时推送草稿呈递；**等待事件无超时**；
   跨会话定时提醒 / 事件唤醒不支持（诚实限制第 8 条）。

### 阶段 5 — upstream PR（双硬前置）

**双硬前置（缺一永不创建）**：① 用户已在阶段 4 载体上完成自审并当会话明确批准；
② 关联 issue 存在（[USER] **无 issue 不开 PR，完全不豁免**——typo/doc/follow-up 一律
从 issue 起步；原 issue 已关 → 新建或 reopen issue 引用原 PR）。

1. **开 PR 前查重**：`gh pr list -R <upstream> --state open --search "<主题词>"` +
   `git log --oneline -20 <upstream>/<默认分支> -- <path>` + issue 末态复核（已被他人
   修复 / 关闭 → 呈报重议，不硬开）。
2. **自动组装（全部对照规则包）**：
   - **标题**：按包 §title（**人工永不写 `(#N)` 尾缀**——squash 自动追加的是 PR 号，
     [MECH]）。**结构化门**：呈批时必须**复述所用标题格式及其来源**（"标题格式
     <格式>，来源：规则包 title 节，原始出处 <工件>"）——自证读了规则源，不复述
     不得创建。
   - **正文**：按包 §template 段落清单逐段组装 + **issue 关联按轴4 issue-link-channel**
     （常见 = 正文 `close #N` 关键字——只有正文 closing 关键字能自动关闭 issue，标题
     里的号 GitHub 不解析，[MECH]）+ **AI 披露**（[USER]：正文自愿附加
     `Assisted-by: <模型名称:版本号>`；包 §template 记载项目模板有 AI 段则填入该段，
     无则自愿附加）+ 应附证据清单按包 evidence-types 维度（benchmark / license /
     检查单 / ai-trailer 等，按改动面给出）。
   - **base** = 轴1 default-branch；**head** = `<owner>:<branch>`；umbrella 任务按包
     issue-pr-relation 维度挂接（如正文 `Main Issue: #N`，收尾不 auto-close 父
     issue）。
3. **创建 = 批准门**：批准卡（命令原文 `gh pr create -R <upstream> --base <默认分支>
   --head <owner>:<branch> --title ... --body-file <f>`；风险 = 向官方仓库提交公开
   PR、进入社区 review 视野；随卡呈报标题格式来源 + 正文全文；替代 ≥2 项；30min
   未批 → park）。
4. **首贡献 approve-label 门控提示**：PR check 出现 waiting / 未跑 → 按包 §ci 首贡献
   批准链解读并提示用户（草拟请求批准评论出卡），不当失败处理。
5. PR 模板合规自检的完整执行细则（证据链卡 / 夹带拦截 / 对抗性自审）遵循
   apache-commit-pr。

### 阶段 6 — review 迭代

1. **拉取与呈报**：`gh pr view <N> -R <upstream> --comments` + `gh api
   repos/<upstream>/pulls/<N>/comments`（只读）→ 评论**带编号列表**呈报（#1、#2……：
   作者 / 位置 / 要点一行）——远程分条指令（"2、3 条改了推上去"）的数字指代依赖此
   格式可解引用。
2. **三路处理（逐条分类后成组执行；任何评论未经用户过目不发布）**：
   - **同意改**：修复 → §pre-commit 门禁 → **commit+push 本轮套餐卡**（同阶段 4
     模板；标题守 §title）；
   - **有据反驳**：草拟回复（技术化、非防御）→ 呈用户过目 → 评论批准卡（公开回复
     构成声誉资产）；
   - **追问**：草拟澄清问题，同评论批准卡路径。
3. **更新方式**：按包 pr-update-style 维度分派（rebase / merge / push-only——项目
   纪律值必须来自本仓证据）；rebase / 合并遇冲突 → 逐块呈报 upstream log/blame
   上下文 + 分级提议，**绝不静默选边**；maintainer 已直接编辑 PR → fetch 同步后呈
   diff。
4. **范围边界**：review 意见隐含 scope 扩大 → 回 issue 层对齐（更新 issue 评论 /
   范围），确认新范围才动手——不擅自扩大（与夹带拦截同源，细则见 apache-commit-pr）。
5. **ping 时机**：停滞 1-2 周 → **in-thread 礼貌 ping，不私聊**；ping 前**查发版
   节奏**——release 窗口 / 投票冻结期停滞是高频外因（代理数据源 = 包 §misc
   release-branch-activity），勿误判为被忽视；新公共 API 等待期同判（包 §ci / §misc
   等待期记载）。stale 风险阈值读包 §misc（stale 天数配置）。
6. **"这轮都批"对话化**：用户分条指令 = 会话作用域范围授权——本轮 commit+push+指定
   评论一次覆盖、不再逐张请卡（每步留痕任务日志）；**远端写永不进永久免批**，跨轮
   新写另卡。
7. 会话内轮询建议同阶段 4（新评论到达 → 即时推送草稿呈递）。

### 阶段 7 — 收尾与去留

1. **合并收尾**：验证合并结果（squash 语义：PR 标题/正文成为 commit message，
   [MECH]；合并按钮态读包轴3）→ **删分支**：`git branch -d <branch>`（本地 git 写）
   + `git push origin --delete <branch>`（远端写）——**同卡打包、远端写单列确认**
   → backlog 归档（状态机推进至"已合并"）→ 衔接阶段 0.5 推荐下一任务（闭环）。
   intra-fork-PR-only 形态另关残留 intra-fork PR。
2. **去留规则（逐 PR 定位，建议呈用户裁决；去留动作均出批准卡）**：
   - 活跃（有未回复评论 / CI 待处理）→ 行动项，不走去留；
   - **2-3 次 ping 无果** → 体面退出选项：换 reviewer 提及 / 转包 §routing 讨论渠道
     / close + 致谢；
   - **方向性否决** → 尊重决定 + **教训沉淀进规则包 P 层提议**（diff 预览 + 来源
     标注"用户纠正/决策考古 <日期>" + 批准落盘入 §manual-research；拒绝 = 只改
     本次）；
   - **issue 被关 wontfix / bot 关闭** → 停止投入（区别于"被抢"，按呈报模板告知
     用户），PR 相应收线；
   - **自解决 / 外部已修** → 草拟 issue close 说明，留给后来搜索者。
3. **优雅放弃**（用户"这个先不做了"）：**释放认领评论必选**（"taking this"的对称
   履约——不告而别 = 留下死认领，bad form）→ 清理本地 / 远端分支（删远端 = 批准卡）
   → backlog 标记可捡回 → intra-fork-PR-only 形态另关 intra-fork PR。

### 安全漏洞改道（全局硬分支——任何阶段命中即中止 PR 流程）

- **检测**：变更或调查中出现漏洞语义（RCE / 认证绕过 / 敏感信息泄露 / 注入类）→
  立即触发，不问进度。
- **中止**：不建 issue、不开 PR、不在任何公开评论 / PR 正文描述漏洞细节或复现步骤
  （已存在的公开载体不含漏洞细节；处置呈报用户）。
- **改道**：私密渠道读包 §routing 安全条目；包缺失或该条标注未证实 → 按 ASF 默认
  私密渠道推断并**标注"未证实"、用前呈报用户**（错地址 = 漏洞报告丢失，不对称
  风险）。
- 改道后按项目安全流程（embargo / 协调披露）走；七阶段中与本分支冲突的段落声明
  不适用。

## 状态与跨会话

1. **三源重建**（续接 / 盘点时先做，**先汇报后动手**）：① **git 现场**（
   `git fetch <upstream> --prune` 后的分支 / 工作树 / 远端布局）；② **fork 侧实体**
   （intra-fork PR、分支、run 状态——按 ci-carrier 形态存在；含 upstream PR 读数，
   gh 只读）；③ **任务日志**（`docs/tasks/backlog.md` 状态机：候选 → 已认领 →
   开发中 → fork 审查中 → upstream PR → 已合并（+ 放弃 / 外部关闭）；复杂任务加
   `docs/tasks/<issue>-<slug>.md` 每任务清单）。三源交叉校验，陈旧即标注——**绝不
   断言未 fetch 的状态**。
2. **续接纪律**：三行汇报（你在哪 / 已完成什么 / 下一步是什么）→ 环境复核（Step 0
   重走 + fetch 防漂移）→ 才动手；**绝不重跑另一会话已完成的工作**；不残留半批准
   状态（中断即存档入任务日志）。
3. **跨仓切换**：显式确认目标仓 → 重走 Step 0 加载该仓规则包（规则包按仓 keyed，
   **绝不把 A 仓规则用于 B 仓**）；"我的 PR"跨仓问法 = 逐仓分别走。
4. **多 PR 仪表盘**：`gh pr status`（当前仓上下文）/ `gh pr list --author <me> -R
   <repo>` 组织一张表：仓 / PR# / 分支 / 阶段 / CI / review 未回复 / stale 风险 /
   需行动——需行动项高亮；去留定位接阶段 7 规则。
5. **任务日志纪律**：每次阶段转移即时写回（与设计文档 changelog 同纪律）；"这轮
   都批"授权范围与执行留痕同记于此。

## Hard guardrails（标准文案，全仓一致）

灾难级规则分层兜底：规则包 §guardrails 置顶节 → 结构化门（阶段 5 呈批复述标题格式
及来源）→（若在）仓内本地 AGENTS.md 指针 → 批准门控最后背书。

- NEVER push to the official Apache remote（`github.com/apache/<project>`，whatever
  it is named）. PRs only — the personal fork is the only staging area.
- NEVER open an upstream PR without a linked issue（user rule，zero exceptions——
  typo/doc/follow-up 一律从 issue 起步；原 issue 已关则新建/reopen issue 引用原
  PR）. 关联通道按规则包轴分派。
- NEVER hand-write the `(#N)` title suffix——GitHub squash 自动追加的是 PR 号。
- NEVER force-push 共享分支（对自己协调过的 PR 分支 force-push 可接受）。
- NEVER commit 凭据、IDE 文件、构建产物、日志及其他私有工件；新文件带 Apache-2.0 头
  （[ASF]，ALv2）。
- NO git/gh write operation without explicit approval in the current session（批准卡
  五要素；"这轮都批"是会话作用域减压阀，远端写永不进永久免批）。
- Security 漏洞永不走公开 issue/PR——改道私密渠道（见「安全漏洞改道」硬分支）。

## Honest limitations（残余风险，均已接受）

> **文案源**：本节 8 条逐字内联自 A4 aux-docs「诚实限制节」（单一文案源，防两份
> 漂移；8 条版已与源同步，2026-10-14）；位置紧随 guardrails 节后（R1-7A）。

本套件依赖概率触发与本地文件读取，以下残余风险已知且被用户接受（2026-10-13）：

1. **触发是概率性的**。skill 无确定性调用作为主路径（`/apache-*` 显式斜杠调用
   仅作兜底逃生口）；description 已按官方建议设计，但任何自然语言触发都不能保证
   命中。
2. **规则包可能被非目标路径旁路**。普通会话未触发本 skill 而顺手执行 commit/PR
   时，规则包不会被读取、规范自检不发生；批准门控是最后背书（一切 push/PR 仍需
   显式批准，旁路产生的结果也会以提案形态到达用户眼前）。
3. **kyuubi 无可控的 AGENTS.md 常驻通道**。其 AGENTS.md 是被追踪的 upstream 资产
   不可修改，本套件灾难护栏无法注入该常驻通道（其既有按名识别远端规则与 skill
   按 URL 识别冲突时，呈报用户裁决，禁止静默择一）；该仓护栏由规则包置顶节 +
   结构化门 + 批准门控三层承载。
4. **陈旧 G 层可能误导跳读者**。冲突裁决序为 [USER] 政策层 > P 层项目事实 >
   skill 正文 > G 层快照——正文永远权威；但只读到 G 层、未读正文的会话可能拿到
   过期的通用规则快照。
5. **软惯例仓的标题漂移仅 90 天时间兜底**。无标题 lint workflow 且无合并改写脚本
   的仓库，社区标题惯例漂移不引起 CI 工件变化，cache 的事件触发永不命中，只靠
   `verified` > 90 天的时间触发重挖。
6. **异机 fresh clone 并存期存在让渡残余**。本机不存在旧项目级 skill 时，Step 0
   第 0 条让渡检查无可让渡对象；此窗口内靠批准门控背书（一切远端写仍需显式批准）。
7. **桌面 app 在线是远程指令/批准能力的前提**。Bot Channel 是桌面 ZCode 会话的
   远程界面而非独立移动执行环境（执行者恒为桌面会话）；桌面会话休眠/退出时，手机
   侧指令（含批准）不可被处理——环境事实，不做唤醒类设计。
8. **跨会话定时提醒/事件唤醒不支持**。cron 轮询（CI 完成、review 新评论等会话内
   提醒）仅在会话存续期内有效，会话结束即失效；跨会话定时提醒无载体，需用户重新
   发起会话（R1-2A 裁定，2026-10-13）。

以上均为计划（v2.5/v2.13-v2.14）与 R1 投票（2026-10-13）明载并接受的残余风险，
不以进一步设计消除。

## 内联挖掘程序（首次采集 / 新仓 bootstrap / 失效重挖共用引擎；本文自包含，与 apache-commit-pr 同文双载）

**cache 语义**（P 层三特性）：**非必须**——cache 缺失是正常态而非错误（新仓接入 /
首次执行 / fresh clone / 被清理）；不依赖它也能工作，缺失时的正确行为是当场在线挖掘
（本程序，只读、分钟级）再行动，而非拒绝任务或猜测规则。**非静态**——时间
（`verified` > 90 天）+ 事件（CI 工件有变更）双触发失效重挖，无需人工维护。**有则
增强**——命中即直用、无须再次采集；操作精确到项目真实门禁，专业性 = 每条可追溯到
来源工件。

**输入（全部只读、免批准）**：

- `.github/workflows/*`（触发器 / jobs / steps 命令 / 矩阵 / permissions / secrets
  依赖）
- CI 脚本目录（`tools/`、`dev/`、`build/` 等惯用目录）
- lint/format 配置（spotless / checkstyle / `.licenserc.yaml` / scalafmt /
  pre-commit hooks 等）
- `.asf.yaml`（merge buttons + 保护分支 + notifications）
- PR/issue 模板（`.github/PULL_REQUEST_TEMPLATE*`、`.github/ISSUE_TEMPLATE/*`）；
  labeler / dependabot / renovate 配置
- CONTRIBUTING / 贡献文档
- git 抽样：`git log --oneline -100 <upstream>/<default>` 标题形态
- PR 标本：~20 条 open + ~20 条 merged PR 标题（匿名 API 可用）

**三步机械推导**（覆盖绝大多数轴；方法已在多个 ASF 仓抽样实战验证）：① `.asf.yaml`
+ workflow 触发器 → merge-governance / default-branch / ci-carrier / `(#N)` 语义 /
release-branch-pattern；② 模板 + PR 标本 → issue-link-channel / 模板段清单 / AI
披露段有无；③ CI steps + 脚本与 lint 配置 → 门禁清单 / 本地测试命令 / label 筛选
词汇。

**派生映射**：workflow 触发器 → ci-carrier 轴 + fork 可跑性（secrets 依赖分析）；
CI steps 中本地可预跑的命令 → 门禁清单；标题 lint workflow → 标题治理态 + 标题
规则；测试矩阵（JDK/OS/引擎 profile）→ 本地复现命令 + "本地过 ≠ CI 必绿"提示
（列出矩阵维度）；PR/issue 模板 → 模板段与筛选面输入；`.asf.yaml` →
branch-protection 轴；labeler 路径映射 → label 筛选词汇（**必须来自本仓一手清单，
禁止跨仓继承**）。

**产出落盘**（经批准后）——规则包结构（schema-version 1；完整母版见
`~/.zcode/skills/apache-dev-workflow/templates/rule-pack-template.md`，母版缺失时
按此骨架落盘）：

- 头部：`schema-version: 1` / `kernel-version:`（= 本文 Changelog 当前版本）/
  `verified: <今天>`（包级失效判据）。
- **Layer G**（通用规则快照，generated read-only，抗跳读冗余）：g-guardrails +
  g-kernel 两节，由种子模板机械再生、禁手改；可后补（非必须）。
- **Layer P**（项目 cache）：轴值头（upstream / default-branch /
  release-branch-pattern / merge-governance / issue-link-channel / ci-carrier /
  branch-protection / target-branch-backport / pr-update-style / evidence-types /
  issue-pr-relation）+ 各节（**guardrails（项目灾难级护栏，置顶）** / title /
  template / pre-commit / ci / filter / routing / local / misc / manual-research）。
- 每条 P 层值带一行出处（文件/命令/API + 日期）；挖不出的字段记 `unknown` + 取材
  尝试说明，**禁止照搬他仓值**。

**新包附加步骤（bootstrap）**：镜像个人母本（`cp` 至
`~/.zcode/rules/<project>.md`）；确认 `/.zcode/` 已 gitignore；[USER] 两规范
（无 issue 不开 PR + AI 披露）默认写入每个新包，并向用户确认一次适用性。

**失效重挖**（时间 > 90 天，或 CI 工件自 `verified` 后有 git 变更；**判定前先
`git fetch <upstream> --prune`**）：包级重挖，diff "cache ↔ CI 实际配置"，漂移则
更新。**重挖纪律**：mining 条目更新；**manual 考证条目**（软惯例 / 历史反模式 /
运营规则——CI 工件派生不出的）收在 manual-research 独立子节，**重挖永不覆写**，
存疑呈报；**guardrails 节中标注〔manual〕的摘要行重挖时不可删**（灾难级规则双写
形态：guardrails 摘要 + manual-research 全记录 + 交叉引用）。

**实战改进注记（2026-10-14 场测修订——B3 seatunnel 首采 + B4 dolphinscheduler 闭卷考合并）**：
1. 输入清单补充：`.github/actions/*` 复合 action（常藏 spotless/license 等门禁实现，
   仅看 workflows/*.yml 会漏）；项目官网 contribute/subscribe/security 三页（社区
   礼仪与安全渠道的最强成文证据，比 PR 标本更权威）。
2. PR 标本取法（API 端点写明）：`pulls?state=closed&per_page=N` 拉回后过滤
   `merged_at != null`（closed≠merged）；open 标本仅在 merge-governance=soft-convention
   态才有必要（ci-lint 态下 open 标题也被强制合规，贡献为零）。
3. 匿名 API 限流：search 接口 10 次/分钟且失败时可能返回空 body 而非 JSON 错误——
   label/issue 计数优先用 REST 端点 + URL 全编码查询，重试间隔 ≥7s。
4. 推导线补充：.asf.yaml 保护分支 `contexts` 里的检查名（如 "Title Validator"）→
   反查 workflows/ 与 `.github/*bot*.yml` 机器人配置定位门禁实现（门禁名与实现
   常分居两处工件）。
5. 证据强度排序提示：贡献文档的成文规定 > PR/commit 标本统计（issue 通道等字段
   文档常给出三分之二证据）。
6. 计时型字段（快门禁时长/矩阵规模）：允许继承上一次 verified 值并标注〔继承〕，
   不强制重测（重测需 run 标本采样，超出常规输入面）。
7. vestigial/失修配置（bot 配置拼写错误、正则失配）：入 manual-research 注记
   "勿依赖"，不作为派生依据。
8. 污染自检（bootstrap 后）：检查项用语义级而非工具名——如"PR 标题节是否出现
   无 issue 号的 `[Type][Module]`"，而非 grep 工具名（目标仓自身合法使用同名
   工具会造成误报）。


## Changelog

- **1.0-draft-2026-10-14**：初稿（Phase A Wave2 · A2 交付物）。内核构成：Step 0
  七条加载协议（**与 apache-commit-pr 逐字同构**）+ [USER] 政策操作层（R1-12 字面
  全拦 + 批准卡五要素 + 本轮套餐卡 + "这轮都批"减压阀）+ 七阶段骨架（0 一次性设置
  [ci-carrier=push-direct 时 Actions 必启] / 0.5 backlog 画像匹配[偏好节载体
  R1-1A：backlog 头部偏好节；撞车三查；Top 2-3 +"为什么适合你"+时间盒过滤] /
  1 issue[先搜后建 + 提案先行：大变更走 §routing 提案通道、绿灯信号后进阶段 2] /
  2 分支[基点轴1、backport 走 target-branch-backport+轴2、命名 §misc] / 3 本地验证
  [§pre-commit 检查链 + §local 定向测试；本地过=必要非充分] / 4 fork 暂存+CI+自审
  [本轮套餐卡；ci-carrier 三态分派；五态四列解读报告；flaky 降级措辞 R1-3A；会话内
  轮询 R1-2A；手机自审载体] / 5 upstream PR 双硬前置[结构化门复述标题格式及来源；
  查重；轴4 关联 + AI 披露；首贡献 approve-label 门控提示] / 6 review 迭代[带编号
  列表 R1-5A；三路处理；pr-update-style 分派；maintainer edits 同步；ping 1-2 周
  in-thread + 发版节奏查 §misc release-branch-activity R1-4A] / 7 收尾与去留[删分支
  同卡；去留规则；教训沉淀 §manual-research；优雅放弃释放认领必选]）+ 安全漏洞改道
  全局硬分支（§routing 渠道 + 未证实标注 R1-8B）+ 状态与跨会话（三源重建 / 先汇报
  后动手 / 跨仓切换 / gh pr status 仪表盘）+ 硬护栏标准文案 + 诚实限制节（紧随
  guardrails，R1-7A；文案源 = A4 aux-docs「诚实限制节」8 条版逐字内联，含第 8 条
  跨会话提醒不支持 R1-2A，源已于 2026-10-14 同步）+ 内联挖掘程序（与
  apache-commit-pr 同文双载，修订须两文件同步）。
  **轴/节消费全覆盖**：六轴（1→阶段 2/5；2→阶段 2；3→阶段 6/7；4→阶段 5；5→
  阶段 0/4；6→阶段 6）+ 4 维度（target-branch-backport→阶段 2；pr-update-style→
  阶段 6；evidence-types→阶段 5；issue-pr-relation→阶段 5/7）+ 十节（guardrails→
  总则；title→阶段 4/5/6；template→阶段 5；pre-commit→阶段 3/6；ci→阶段 0/4/5/6；
  filter→阶段 0.5；routing→阶段 1/6/7+安全改道；local→阶段 3；misc→阶段 2/6；
  manual-research→阶段 7）。**安装形态：本文件 →
  `~/.zcode/skills/apache-dev-workflow/SKILL.md` + 种子模板 →
  `templates/rule-pack-template.md`（A3 草案即母版）。kernel-version 回填注记：本
  文与 apache-commit-pr（1.0-draft-2026-10-13）属同一内核，版本日期差仅为撰写日；
  G0b 定稿时统一回填。**

### B5 干跑修订（2026-10-14 实测回写）
1. **add 一律显式文件路径，禁 `git add -A` / `git add .`**——工作分支基于
   upstream 基点时，本地未上游化的 gitignore 增强不生效，工作区私件（计划文档/
   规则包缓存）以未跟踪态暴露在 add 面（B5 实测踩中）。
2. **阶段 3 增环境前置检查**：JDK/工具链与规则包 §local 矩阵对照——本机可用
   版本都不匹配（如项目 source 11 而本机仅 8/21，8 编不过、21 崩旧版 spotless 的
   javac 内部 API）时：切换可用 JDK 或降级为差距项显式呈报，不得静默跳过。
3. **挖掘铁律（CI 工件直读）**：本地克隆可能落后 upstream 数千提交——backend.yml
   等 CI 工件直读须对照 upstream 最新引用（`git show <upstream>/<branch>:<path>`）
   并记基点 SHA，否则矩阵/触发面会记成过期事实（B5 实测：矩阵实为 11/17，旧包记
   8/11 即此因）。
4. **阶段 0.5 偏好节空源分支**：对话无可提取偏好陈述时以 unknown 占位建节并提示
   用户陈述，不得虚构偏好或阻塞流程。
5. **批准卡任务号允许非 issue 标识**（干跑/运维/合成任务场景，如 "B5-dryrun"），
   卡结构不变。
