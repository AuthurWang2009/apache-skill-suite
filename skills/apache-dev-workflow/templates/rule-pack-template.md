# Rule pack 种子模板（schema-version 1）

> A3 交付物 · 2026-10-13 · 依据 apache-skill-suite.md §2.2/§2.3/§2.4/§4.2
> 用途：新仓 bootstrap（§0.1/§0.2 挖掘程序）与内核升级时 G 层机械再生的母版。
> 本文件是**模板**：`<>` 为占位符；注释块（`<!-- -->`）说明取材处与派生映射，落盘时保留或按需精简，但**每条 P 层值的出处行不可删**（专业性=可追溯）。

---

## 使用纪律（模板级，随包复制）

1. **G 层与 P 层职责边界严格**：[USER] 政策**只出现在 G 层 g-guardrails**；P 层对 [USER] 政策只能记录项目侧偏差事实并呈报用户（如"社区 0/6 用 close 关键字"），不得覆盖、不得豁免。
2. **冲突裁决序**（2026-10-13 用户已确认）：[USER] 政策层（不可被覆盖，仅用户显式豁免可解除）> P 层项目事实 > skill 正文（非 [USER] 内核）> G 层快照。G 层是抗跳读冗余，**skill 正文永远权威**。
3. **P 层 cache 语义**：非静态（`verified` >90 天或 CI 工件自该日后有变更 → 包级重挖；判定前先 `git fetch <upstream> --prune`）、非必须（缺失是正常态 → 当场在线挖掘，不猜不借）、有则增强（命中直用，无须再采）。
4. **条目双型**：`mining`（可由 §0.2 程序从 CI 工件机械重挖）分布于各节；`manual`（regeneration: manual，软惯例/历史反模式/运营规则，不可机械重建）**只收在 §manual-research 独立子节**——重挖不覆写该节；丢失靠"个人母本 + docs/plan 归档"双备份兜底。
5. **每条 P 层值必须带一行出处**（文件/命令/API + 日期）；挖不出的字段记 `unknown` + 取材尝试说明，**禁止照搬他仓值**。
6. schema-version 不认识的包 = 按"缺失"降级（结果仅内存使用，不覆写原包）并呈报用户。

---

```markdown
# Rule pack: <project>
<!-- 单一事实来源：apache-commit-pr / apache-dev-workflow / 文档三消费方共读。
     位置：<repo-root>/.zcode/rules/<project>.md（gitignored 工作副本）
     + ~/.zcode/rules/<project>.md（个人母本，双层持久化）。 -->

schema-version: 1
kernel-version: <apache 内核版本>   <!-- 信息性：G 层生成来源。内核升级时用本模板分段替换 G 层、
                                        保留 P 层（A4 非必须刷新程序）；不构成权威，陈旧 G 无害。 -->
verified: <YYYY-MM-DD>             <!-- 包级 cache 失效判据之一（>90 天）；判据之二 = CI 工件
                                        （workflows/lint 配置/模板/.asf.yaml）自该日后有变更。 -->

# ===== Layer G：通用规则层（generated, read-only）=====
<!-- 本层由种子模板预置，随内核版本机械再生，禁止手改（防内核↔包漂移）。
     G 层是抗跳读冗余：skill 正文永远权威；冲突序中 G 层位于最末。
     内容来源 = 计划 §2.2 写死层三级（[USER] 用户政策 / [MECH] 引擎机制 / [ASF] 基金会政策），
     逐条标注置信依据。G 层不含任何项目事实（标题语法/分支名/命令值/label 均在 P 层）。 -->

## g-guardrails
<!-- 通用硬护栏标准文案，全仓一致。[USER] 政策只出现在本节。 -->

- [USER] 批准门控（user rule, stricter than community norms）：一切 git/gh 写操作
  （push、PR、issue 写、cache 落盘、CI retry）须经当会话用户明确批准；远端写永不进永久免批。
- [USER] 无 issue 不开 PR（user rule, stricter than community norms）：一切 PR 从 issue
  起步（含 typo/doc/follow-up；原 issue 已关闭时新建或 reopen issue 引用原 PR）。
  完全不豁免（用户裁决 2026-10-13）。关联通道（标题前缀 or 正文 close #N）由 P 层
  issue-link-channel 轴分派，本条不指定通道。
- [USER] AI 披露政策（user rule）：PR 正文自愿附加 `Assisted-by: <模型名称:版本号>`
  （如 `Assisted-by: ZCode:GLM-5.3`）；P 层 template 节记载项目模板有无 AI 段——
  有则填入该段，无则自愿附加；永不将 AI 列为 co-author；源码/注释/标题/commit message
  中无 AI 自我引用（ASF Generative Tooling Guidance 框架）。
- [ASF][USER] 永不 push 官方远端（apache/<project>，无论远端名）：PR-first 贡献流，
  个人 fork 是唯一暂存区。
- [MECH][USER] 永不 force-push 共享分支（对自己协调过的 PR 分支 force-push 可接受）。
- [MECH][USER] 永不提交凭据、IDE 文件、构建产物、日志及其他私有工件；新文件带
  Apache-2.0 头（[ASF]，ALv2）。

## g-kernel
<!-- 引擎机制与基金会政策快照（与仓库无关），+ 跨仓提示。 -->

- [MECH] squash 合并语义：PR 标题与正文成为 merge commit message——scope 扩大时
  标题与正文必须同步更新。
- [MECH] `(#N)` 尾缀（含 backport 场景双尾缀）= squash 自动追加的 **PR 号**（非 issue
  号），人工永不手写；只有正文 closing 关键字（close/fix/resolve #N）能自动关闭
  issue——标题里的 issue 号不被 GitHub 解析。
- [MECH] 标题治理三态提示：ci-lint（workflow 强制）/ merge-tool（合并脚本改写）/
  soft-convention（软惯例统计）。跨仓警告：title conventions are repo-specific and
  sometimes mutually exclusive——具体形态永远以 P 层 title 节为准，禁跨仓套用。
- [MECH] CI 排查命令模式：`gh run list -R <repo> -b <branch> -L 5` →
  `gh run view <run-id> -R <repo> --log-failed`（→ `-j <job-id>` 下钻）；
  失败分类：真 bug / 环境 / flaky / 未跑（首贡献待批准）/ 规范门禁（不可 rerun 救）。
- [MECH] 上游识别是程序不是常量：远端 URL 对照（github.com/apache/<project> 仅快
  路径）→ fork 血缘 API（`GET api.github.com/repos/<o>/<r>` → `.source.full_name`，
  嵌套 fork 取 source）→ 归属判断（apache 组织或 .asf.yaml → ASF 合规清单，否则
  ASF 项 N/A）→ 均失败问用户。
- [ASF] issue 礼仪默认值：先搜后建、评论认领（"taking this"；非 committer 不能
  self-assign）；仓内有更具体礼仪时以 P 层/filter 与 routing 节为准。
- [ASF] ICLA 政策框架：偶尔 PR 无需 ICLA（ALv2 clause 5）；持续实质贡献/committer
  提名前签署（个人邮箱，与 git config 邮箱一致）。

# ===== Layer P：项目 CI/CD 规则缓存（cache——可再生的增强层，非必须）=====
<!-- 采集：§0.2 挖掘程序（首次执行时采集填充；§0.1 三步可机械推导 6 轴中 5 个：
     merge-governance / default-branch / ci-carrier / (#N) 语义 / release-glob）。
     每值一行出处（文件/命令/API+日期）。轴值为单行摘要，细节在下列各节展开。 -->

upstream: <owner/repo 完整 URL>                <!-- Step 0.1 识别产物；取材：git remote -v -->
default-branch: <dev|master|main>              <!-- 轴1：保护分支名 + git symbolic-ref 双确认 -->
release-branch-pattern: <glob>                 <!-- 轴2：dev-workflow 分支基点/backport 咨询用；
                                                    apache-sync-fork 不读取（同步集自包含） -->
merge-governance: <合并按钮（源 .asf.yaml enabled_merge_buttons）+ 标题治理态
                  （ci-lint|merge-tool|soft-convention）>   <!-- 轴3：取材 .asf.yaml + 标题 lint
                                                    workflow 有无 + 合并改写脚本有无 -->
issue-link-channel: <pr-body-close|title-prefix|none-soft> <!-- 轴4：取材 PR 模板/合并脚本/
                                                    merged PR 标本（closing 关键字使用率） -->
ci-carrier: <push-direct|upstream-pr|intra-fork-PR-only>   <!-- 轴5：取材 workflow 触发器
                                                    （push 通配/pull_request/fork 侧唯一途径） -->
branch-protection: <reviews 数 + strict 开关（→ rebase 纪律）>  <!-- 轴6：取材 .asf.yaml
                                                    protected_branches；无配置则记实况 -->

# —— 头脑风暴新增 4 维度（总库「主会话已裁」#2，2026-10-13 落位 P 层头部）——
target-branch-backport: <新工作 base 分支 + backport 策略（谁执行/如何/后缀惯例）>
                         <!-- B2 场景：取材贡献文档 + 合并脚本 + release 分支观察；
                              挖掘不出 → unknown，禁猜 -->
pr-update-style: <rebase|merge|push-only + 项目已知纪律>   <!-- D4 场景：取材 branch-protection
                              strict 开关 + 贡献文档；Spark rebase / Pulsar 禁 rebase 互斥，
                              项目值必须来自本仓证据 -->
evidence-types: <benchmark|license|checklist|ai-trailer|test-justification 的本项目集合>
                              <!-- B6/B7/B10 场景：取材 PR 模板必填段 + CI 门禁 job +
                              known-dependencies/LICENSE 检查；H6 证据链卡消费 -->
issue-pr-relation: <1:1|umbrella（挂接语法）+ 豁免类=无（[USER] 2026-10-13 完全不豁免）>
                              <!-- B1/B9/E5 场景：取材 issue 模板（umbrella 形态）+ 社区
                              PR 标本；豁免类恒为"无"——[USER] 政策，P 层不得改写 -->

## guardrails
<!-- 项目灾难级护栏（置顶节，§2.5 分层第①层）：标题格式字面示例、禁合并项、
     分支基点、项目特有的"做了即灾难"操作。取材：本节是 P 层各节中灾难级条目的
     汇总呈现，派生映射 = title/ci/misc 各节灾难条目上提；旧 skill Hard guardrails
     节整段迁入此处（no rule lost）。注意：与 G 层 g-guardrails 互补——G 层是全仓
     通用文案，本节只放项目特有事实。 -->

## title
<!-- 标题规范全文：形态/类型词/组件词/反模式，逐条带出处。取材（§2.2 三重判态）：
     ① 有标题 lint workflow → ci-lint 态（读 workflow 配置）；
     ② 有合并改写脚本 → merge-tool 态（读脚本正则与改写行为）；
     ③ 皆无 → soft-convention 态（git log --oneline -50 <upstream>/<默认分支> 标题
     模式统计 + 贡献文档标题节）。反模式（never-mimic 类）与 (#N) 引擎规则衔接。 -->

## template
<!-- PR 模板段落清单 + AI 披露段有无及政策落点。取材：.github/PULL_REQUEST_TEMPLATE*
     现读；每段标注必填/选填；AI 段有无 → evidence-types.ai-trailer 与 [USER] 披露
     政策的落点（有则填入、无则自愿附加）。 -->

## pre-commit
<!-- 提交前门禁：本地可预跑命令 + 仓库专属清单。派生映射：CI steps 中本地可预跑的
     命令（§0.2）——style job → 格式化命令；code-spec job → 规范检查命令；license
     job → 头检查/依赖检查；特有检查（如 .class 拦截、五件套）单列。每条注明
     对应 workflow 文件与 step 名。 -->

## ci
<!-- CI 门禁构成 + fork 可跑性 + 启动礼仪 + 快门禁时长。派生映射：workflow 触发器
     → ci-carrier 轴与 fork 可跑性（secrets 依赖分析）；job 依赖图 → 快慢门禁分层
     （快门禁=分钟级反馈环）；首贡献批准链（label/workflow_run 链）→ 启动礼仪。
     已知基线（release 分支飘红等预期噪音）也记此处，供 D5 五态分类用。 -->

## filter
<!-- issue 模板形态 + label/search 筛选面（阶段 0.5 backlog 消费）。派生映射：
     .github/ISSUE_TEMPLATE/* → 模板形态与默认 label；labeler 配置 → PR label；
     issue label 一手清单（API 拉取 + 日期 + 计数）→ 筛选词汇表。硬约束：label
     词汇必须来自该仓一手清单，禁止跨仓继承。 -->

## routing
<!-- 邮件/讨论区/安全渠道。取材：.asf.yaml notifications 段 + CONTRIBUTING/贡献
     文档 + SECURITY.md 有无（无 → 私密渠道按 ASF 默认并标注未证实）；安全漏洞
     永不走公开 issue（B3 全局硬分支，本节只填渠道地址）。 -->

## local
<!-- 构建/测试命令与 profile。派生映射：CI 测试矩阵（JDK/OS/engine profile）→
     本地复现命令 + "本地过 ≠ CI 必绿"提示（矩阵维度列出）。 -->

## misc
- release-branch-activity：（R1-4A）release 分支最近 commit 时间分布——取材：
  `git for-each-ref --sort=-committerdate refs/remotes/<upstream>/*-release`
  或 ls-remote+匿名 API commit 日期；用途：阶段 6 ping 时机前的发版节奏代理判断
 （release 窗口期 PR 停滞属常态，勿误判为被忽视）
<!-- 分支命名（若为 CI/仓库工件可派生）、stale（days-before-* 配置）、license 机制
     （检查工具名）、其他未归类 mining 条目。取材：stale workflow、.asf.yaml、
     构建脚本。注：apache-sync-fork 排除分支字段已删除（其同步集自包含，本包无消费者）。 -->

## manual-research
<!-- 人工考证条目（regeneration: manual）：软惯例/历史反模式/运营规则——凡 CI 工件
     派生不出的（社区流程礼仪、fork 侧运营纪律、词汇表统计、历史事故教训）。
     独立子节隔离：重挖永不覆写本节；存疑条目呈报用户。丢失代价高于 mining 条目，
     靠个人母本 + docs/plan 归档双备份。每条带考证日期与考证方法。 -->
```

---

## 模板自检清单（G0b 评审用）

- [ ] schema 头三字段齐全；kernel-version 标注信息性；verified 为包级判据
- [ ] G 层两节与 §2.2 写死层三级逐条对得上，无项目事实混入
- [ ] [USER] 政策只出现在 g-guardrails；P 层无政策改写
- [ ] 六轴 + 4 维度全部有值或显式 `unknown`（带取材尝试说明）
- [ ] 每条 P 层值带一行出处（文件/命令/API+日期）
- [ ] filter 节 label 词汇全部来自本仓一手清单
- [ ] manual-research 只收 CI 工件派生不出的条目；mining 条目不在该节
- [ ] 旧 skill（kyuubi 迁移时）规则集 diff：no rule lost
