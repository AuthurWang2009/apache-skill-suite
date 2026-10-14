---
name: apache-commit-pr
description: >-
  ASF-generic commit & pull-request conventions, guardrails, and pre-submit
  compliance self-check for any Apache Software Foundation repository. Use
  ONLY when BOTH hold: (1) the repo is Apache (a checkout or fork of a
  github.com/apache project) and (2) the user asks for commit/PR work —
  commit changes, write a commit or PR title, open or update a PR, fill the
  PR template, check changes against the repo's rules before submitting, or
  investigate CI/PR failures, even indirectly ("提交一下", "开个 PR", "CI 挂了
  看看"). Loads or mines the per-repo rule pack (.zcode/rules/<project>.md)
  — never guesses, never borrows another repo's rules. Enforces: no upstream
  PR without an issue, approval gating on every git/gh write, AI disclosure
  in the PR body, never push the official remote. NOT for non-Apache repos;
  fork/branch syncing is the apache-sync-fork skill's domain.
when_to_use: >-
  Trigger on indirect phrasings too ("帮我开个 PR", "开 PR 前帮我过一遍规范",
  "CI 挂了看看", "reviewer 评论了帮我改"). Covers title format, PR body
  template, evidence chain, squash-merge mechanics, backport targets. Do NOT
  trigger for plain git questions (revert/rebase) without commit/PR intent,
  non-Apache repositories, or fork-upstream syncing (apache-sync-fork).
---

# apache-commit-pr — Apache 通用提交 / PR 规范内核

> **定位**：个人级通用 skill。本 skill 管 **commit/PR 时点的规范内核**（远端识别、标题
> 模板框架、门禁框架、PR 模板框架、CI 解读、ASF 合规、硬护栏）；端到端任务编排
> （找 issue → 分支 → 验证 → review → 收尾）归同族 `apache-dev-workflow`；fork↔upstream
> 分支同步归 `apache-sync-fork`（其同步集自包含，不读本套件规则包）。两个通用 skill 同意图
> 双触发时经 Step 0 会话内去重收敛——谁先触发，行为一致。
> **一切仓库特定值（标题格式 / 默认分支 / 门禁命令 / 模板段 / label 词汇……）来自
> 规则包；本正文不含任何仓库规则性事实。**
> **标注体系**：[MECH] = GitHub/gh 引擎机制（与仓库无关）；[ASF] = Apache 软件基金会
> 全项目政策；[USER] = 用户协作约定（user rule, stricter than community norms）。
> **反闭门造车原则**（用户裁决 2026-10-13）：写死的仅限"非常确定"的三级内容——引擎
> 机制 / 基金会政策 / 用户政策；一切项目事实优先在运行时从已 clone 的仓库现读（项目
> 文档 / git 变更摘要与记录 / CI 配置），cache 即现读结果的持久化，miss 当场派生。

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

## 写死层（仅此三级，逐条标注置信依据）

### [USER] 用户政策（user rule, stricter than community norms）

1. **批准门控**：一切 git/gh 写操作须经当会话用户明确批准——**字面全拦**
   （2026-10-13 仲裁）：本地 commit、push、PR/issue/评论写、规则包 cache 落盘、
   CI rerun 全部在内；免批准集合仅限只读操作（见下）。批准的形态 = 用户当会话的
   **明确指令**或对**批准卡的明确答复**；指令覆盖范围以字面为准，含混时收窄解释
   （如"提交一下"默认只覆盖本地 commit，push/PR 另出批准卡）。
   - **批准卡五要素**（全仓统一模板）：① 待批**命令原文逐字**；② **风险**一句话；
     ③ **任务号**（有 issue = `issue #N`；无 issue 的运维场景 = 任务日志条目 ID，
     如 `<分支或主题>-<日期>`）；④ **替代选项**（≥2 个）；⑤ **30min 未批 → park**
     （挂起 + 摘要保留，随时恢复，不自动重试）。
   - **减压阀 = "这轮都批"**（对话化的会话作用域范围授权，如用户分条指令"2、3 条
     改了推上去"）：授权范围内不再逐条请批，但远端写逐条留痕任务日志；**远端写
     永不进永久免批**。
   - 批准门只认会话不认来路：经用户配置的 Bot Channel（不写死信道名）到达的批准
     = 会话内批准；执行者恒为桌面会话（Bot Channel 是其远程界面；桌面 app 在线是
     前提，见诚实限制节）。
   - 事件等待（等 CI 完成 / 等 review 到达）无超时；**等批准**才有 30min park。
   - 免批准只读集合：`git fetch <upstream> --prune`、gh 读取类命令、匿名 API、
     「内联挖掘程序」的全部输入操作。
2. **无 issue 不开 PR**（用户裁决 2026-10-13：**完全不豁免**）：一切 PR 从 issue 起步
   ——含 typo、doc、follow-up；follow-up 场景原 issue 已关闭时，新建或 reopen issue
   引用原 PR 起步。**零例外**。关联通道（正文 `close #N` 关键字还是标题带 issue 号）
   由规则包 issue-link-channel 轴分派，本条不指定通道；P 层记录的社区偏差事实只
   呈报、不适用。
3. **AI 披露**（用户裁决 2026-10-13）：PR 正文自愿附加 `Assisted-by: <模型名称:版本号>`
   （如 `Assisted-by: ZCode:GLM-5.3`）。规则包 template 节记载项目模板有无 AI 段：
   有则填入该段，无则自愿附加。永不将 AI 列为 co-author；源码/注释/标题/commit
   message 中无 AI 自我引用（ASF Generative Tooling Guidance 框架）。

### [MECH] 引擎机制（GitHub/gh 行为，与仓库无关）

1. **squash 合并语义**：启用 squash 的仓库（ASF 主流形态）中，PR 标题与正文成为
   merge commit message——**scope 扩大时标题与正文必须同步更新**；分支内各 commit
   message 不进入最终历史。
2. **`(#N)` 尾缀 = PR 号**：GitHub squash 自动追加的尾缀（含 backport 双尾缀场景）
   是 **PR 号**（非 issue 号），**人工永不写**——手写它等于伪造引擎行为。本仓标题
   具体格式以规则包 title 节为准，但"人工不写 `(#N)`"跨仓不变。
3. **closing 关键字**：只有 PR **正文**中的 `close/fix/resolve #N` 能自动关闭 issue；
   **标题里的号 GitHub 不解析**。需要自动关 issue 时，关联必须落在正文（或按包轴
   分派的等价通道），标题与正文二者不可互换。
4. **fork = 暂存区**：个人 fork 是唯一 push 目标（与 [ASF] PR-first 互为表里）。fork
   侧 CI 形态因仓而异（push 直接触发 / 仅 upstream PR 触发 / intra-fork PR 是唯一
   途径）——**开 intra-fork PR 前必须对照规则包 ci-carrier 轴**：错轨道 = 制造无
   CI 价值且需手动清理的实体。
5. **CI 排查命令模式**：`gh run list -R <repo> -b <branch> -L 5` → `gh run view
   <run-id> -R <repo> --log-failed`（必要时 `-j <job-id>` 下钻单 job）。失败**五态
   分类**（每 job 一行"态 + 依据 + 行动"，无依据不得断言）：
   - **真 bug**：失败定位到本次 diff 涉及的模块/测试 → 回修复循环；
   - **环境**：基础设施/网络/依赖拉取类失败 → 观察或重跑；
   - **flaky**：判定程序弱，措辞降级——"**疑似 flaky → 批准 rerun 验证**"（样本
     积累后再议升格）；
   - **未跑**（首贡献待批准链）：识别 waiting 状态 → 走解锁链（草拟请求批准评论，
     出批准卡）；
   - **规范门禁**（lint/license 类）：**不可 rerun 救** → 必须改代码/补头，回门禁
     清单。
   rerun 属写操作：出批准卡（可入"这轮都批"）。

### [ASF] 基金会级政策

1. **PR-first 贡献流**：个人永不 push 官方仓（`github.com/apache/<project>`，无论
   远端名）；一切变更经 PR + review。
2. **ALv2**：新文件带 Apache-2.0 license 头（从仓内任一既有文件复制）；license
   检查工具可能扫描 gitignored 本地文件——私有文件勿放仓库根。
3. **ICLA 政策框架**：偶尔 PR 无需 ICLA（ALv2 clause 5）；持续实质贡献 / committer
   提名前签署（个人邮箱，与 git config 邮箱一致）。
4. **issue 礼仪默认值**：先搜后建、评论认领（"taking this"；非 committer 不能
   self-assign）；仓内有更具体礼仪时以规则包为准。
5. **安全漏洞改道（硬分支）**：发现安全漏洞（RCE/认证绕过类）→ **中止一切公开
   流程**——不建 issue、不开 PR、不在公开评论描述漏洞细节；改走规则包 routing 节
   的私密渠道；包缺失时按 ASF 默认私密渠道推断并**标注"未证实"**（错地址 = 漏洞
   报告丢失，不对称风险，待考证收口）。

### 硬护栏（Hard guardrails——标准文案，全仓一致）

灾难级规则分层兜底：规则包 guardrails 置顶节 → 结构化门（见「规范自检与证据链卡」）
→（若在）仓内本地 AGENTS.md 指针 → 批准门控最后背书。

- NEVER push to the official Apache remote（`github.com/apache/<project>`，whatever
  it is named）. PRs only — the personal fork is the only staging area.
- NEVER open an upstream PR without a linked issue（user rule，2026-10-13：zero
  exceptions——typo/doc/follow-up 一律从 issue 起步；原 issue 已关则新建/reopen
  issue 引用原 PR）. 关联通道按规则包轴分派。
- NEVER hand-write the `(#N)` title suffix——GitHub squash 自动追加的是 PR 号。
- NEVER force-push 共享分支（对自己协调过的 PR 分支 force-push 可接受）。
- NEVER commit 凭据、IDE 文件、构建产物、日志及其他私有工件；新文件带 Apache-2.0 头。
- NO git/gh write operation without explicit approval in the current session（批准卡
  五要素；"这轮都批"是会话作用域减压阀，远端写永不进永久免批）。

## Honest limitations（残余风险，均已接受）

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

*(Verbatim from aux-docs 诚实限制节, 8-item version synced 2026-10-14; position per R1-7A)*

## 派生层——本仓事实（绝不写死；每条注明取材处）

**总则**：cache 命中直用；miss 当场按下列取材处现读派生（或整体走「内联挖掘程序」），
经批准落 cache。**title conventions are repo-specific and sometimes mutually
exclusive**——禁止把任何仓的形态当作通用默认。

1. **合并按钮与保护分支** → 现读 `.asf.yaml`（merge buttons + `protected_branches`
   段）。
2. **默认分支** → **双确认**：`.asf.yaml` 保护分支名 + `git symbolic-ref
   refs/remotes/<upstream>/HEAD`。
3. **标题规范** → **三重判态**：① 有标题 lint workflow（semantic-PR / pr-title-check
   类）→ **ci-lint 态**（读 workflow 配置取规则）；② 有合并改写脚本（dev/tools 类
   目录）→ **merge-tool 态**（读脚本正则与改写行为）；③ 皆无 → **soft-convention
   态**（`git log --oneline -50 <upstream>/<默认分支>` 标题模式统计 + 项目贡献文档
   标题节）。三态互斥——把 A 仓形态套进 B 仓是翻车主因。
4. **issue 关联通道与礼仪** → PR/issue 模板 + 贡献文档（CONTRIBUTING、
   docs/contributing 类）+ 近期 merged PR 正文样本（closing 关键字使用率统计）。
5. **PR 模板段落（含 AI 披露段有无）** → 现读 `.github/PULL_REQUEST_TEMPLATE*`，
   逐段标必填/选填。
6. **提交前门禁 / CI 细节**（门禁命令、ci-carrier、fork 可跑性、快门禁时长、已知
   基线噪音）→ 「内联挖掘程序」产出（规则包 pre-commit / ci 节）。
7. **正式/私密渠道**（邮件列表、讨论区、安全渠道）→ 规则包 routing 节（.asf.yaml
   notifications + 贡献文档 + SECURITY.md 有无；缺失按 ASF 默认推断并标注
   "未证实"）。

## 内联挖掘程序（首次采集 / 新仓 bootstrap / 失效重挖共用引擎；本文自包含）

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


## 规范自检与证据链卡（push/PR 前门）

**时点**：用户请求"开 PR 前对照规范查一遍"类；或作为 push / PR 批准卡的随卡材料
（diff 概要、证据链卡鼓励随卡呈报）。操作序：本地改码与门禁预跑 → 自检卡 →
commit（批准门控）→ push 批准卡 → fork CI 五态解读 → 结构化门 + PR 批准卡。

**三列证据链卡**（规则 + 来源 + 验证证据；**禁止"✅ 已检查"式无来源断言**）。
检查行至少覆盖：

| 检查项 | 规则（来源=规则包条目） | 验证证据 |
|---|---|---|
| 标题形态 | title 节缓存条目（带原始出处） | 实际标题 + 类型词/组件词命中判定 + 不确定则省略的取舍说明 |
| issue 关联 | [USER] 无 issue 不开 PR + issue-link-channel 轴 | issue 存在性 + 实际关联方式（如正文 close 行原文） |
| PR 正文段 | template 节（模板文件出处） | 逐段有无 |
| AI 披露 | [USER] 披露政策 + template 节段有无 | 正文实际 `Assisted-by:` 行 |
| 门禁清单 | pre-commit 节逐条（各带 CI 工件出处） | 本地实跑命令 + 结果摘要（未跑=差距项，不得标绿） |
| base 分支 | 默认分支轴值（双确认来源） | 实际 `--base` 值 |
| 硬护栏 | g-guardrails | 新文件 ALv2 头检查 + 无凭据/IDE 文件/构建产物/日志的清单证据 |

**夹带拦截**：diff 中与 issue 无关的顺手改动（typo / 无关重构）→ 拒绝混入，建议
单独 issue + PR（[USER] 不豁免：typo 也要 issue）。

**对抗性自审**：以 fresh-context 视角复查自己的 diff（换视角重读，不带"我刚写的"
假设），发现项附进卡片。

**结构化门（`gh pr create` 前强制）**：呈报批准卡时必须**复述所用标题格式及其
来源**（如："标题格式 <格式>，来源：规则包 title 节，原始出处 <工件>"）——自证
读了规则源；不复述不得创建。

## Changelog

- **1.0-draft-2026-10-14**：初稿（Phase A Wave2 · A1 交付物）。内核构成：Step 0
  七条加载协议（让渡前置检查 / 会话内去重 / 上游识别链 a-d / 读包 / 缺失处理 /
  失效判定 / 冲突裁决序 / schema 降级）+ 写死层三级（[USER] / [MECH] / [ASF]）+
  硬护栏标准文案 + 派生层取材映射 + 内联挖掘程序（自包含，统一惰性流）+ 证据链卡
  与结构化门 + 诚实限制节（单一文案源逐字内联，位置紧随 guardrails 后）。R1 投票
  12 项全部生效（含 R1-7 限制节位置、R1-12 批准门控字面全拦 + "这轮都批"减压阀、
  R1-3 flaky 降级措辞、R1-8 routing 未证实标注、A3 附议〔manual〕摘要行保护）。
  **规则包 `kernel-version:` 头回填本版本号（1.0-draft-2026-10-14）。**

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
