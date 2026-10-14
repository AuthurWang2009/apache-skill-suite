# Rule pack: seatunnel
<!-- 单一事实来源：apache-commit-pr / apache-dev-workflow / 文档三消费方共读。
     位置：<repo-root>/.zcode/rules/seatunnel.md（gitignored 工作副本，/.zcode/ 已在 .gitignore:65）
     + ~/.zcode/rules/seatunnel.md（个人母本，双层持久化）。
     B3 首次执行采集产物（2026-10-14，按内联挖掘程序真实跑采）；与 A3 考证版的逐字段
     diff 见 docs/plan/ 执行记录。 -->

schema-version: 1
kernel-version: 1.0-draft-2026-10-14   # 信息性：G 层生成来源；禁手改 G 层
verified: 2026-10-14             # 包级失效判据：>90 天，或 CI 工件自该日后有变更（判定前先 fetch upstream --prune）

# ===== Layer G：通用规则层（generated, read-only）=====
<!-- 由种子模板（~/.zcode/skills/apache-dev-workflow/templates/rule-pack-template.md）预置，
     随内核版本机械再生，禁止手改；G 层是抗跳读冗余，skill 正文永远权威。 -->

## g-guardrails
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
- [ASF][USER] 永不 push 官方远端（apache/seatunnel，无论远端名）：PR-first 贡献流，
  个人 fork 是唯一暂存区。
- [MECH][USER] 永不 force-push 共享分支（对自己协调过的 PR 分支 force-push 可接受）。
- [MECH][USER] 永不提交凭据、IDE 文件、构建产物、日志及其他私有工件；新文件带
  Apache-2.0 头（[ASF]，ALv2）。

## g-kernel
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
- [MECH] 上游识别是程序不是常量：远端 URL 对照（github.com/apache/seatunnel 仅快
  路径）→ fork 血缘 API（`GET api.github.com/repos/<o>/<r>` → `.source.full_name`，
  嵌套 fork 取 source）→ 归属判断（apache 组织或 .asf.yaml → ASF 合规清单，否则
  ASF 项 N/A）→ 均失败问用户。
- [ASF] issue 礼仪默认值：先搜后建、评论认领（"taking this"；非 committer 不能
  self-assign）；仓内有更具体礼仪时以 P 层/filter 与 routing 节为准。
- [ASF] ICLA 政策框架：偶尔 PR 无需 ICLA（ALv2 clause 5）；持续实质贡献/committer
  提名前签署（个人邮箱，与 git config 邮箱一致）。

# ===== Layer P：项目 CI/CD 规则缓存（cache——可再生的增强层，非必须）=====
<!-- B3 采集：2026-10-14 按内联挖掘程序真实执行；全部输入只读（fetch 后 git 现场 +
     匿名 GitHub API + apache.org 官网页）。每值一行出处。 -->

upstream: github.com/apache/seatunnel
  # 出处：git remote -v（upstream = https://github.com/apache/seatunnel.git），verified 2026-10-14

default-branch: dev
  # 轴1。出处：.asf.yaml protected_branches 首键 = dev + git symbolic-ref
  # refs/remotes/origin/HEAD → origin/dev（fork 侧默认分支同向），verified 2026-10-14

release-branch-pattern: "<X.Y.Z>-release"（glob: *-release；共 18 个：2.1.1–2.1.3、
  2.3.0–2.3.13、3.0.0）
  # 轴2。出处：git ls-remote --heads upstream | grep 'release$' 计数 19（含 1 个
  # 杂项 *_start_latch_release，纯 release 分支 18 个）+ for-each-ref 快照，
  # verified 2026-10-14。注意：与 kyuubi 的 branch-* 形态互斥——禁跨仓套用

merge-governance: GitHub squash（merge/rebase 按钮禁用）+ 标题治理态 = soft-convention
  # 轴3。出处：.asf.yaml enabled_merge_buttons（squash: true, merge: false,
  # rebase: false）直读；标题治理态 = 无标题 lint workflow（.github/workflows/ 清单
  # 实证 13 个文件：add-label/approve-label-trigger/approve-label/backend/build_main/
  # codeql/labeler/notify_test_workflow/publish-docker/publish-helm-chart/
  # schedule_backend/stale/update_build_status，无 semantic-PR/pr-title-check 类）+
  # 无合并改写脚本（tools/ = dependencies/documents/github/spotless_check/
  # update_modules_check，无 merge_*）→ soft-convention，verified 2026-10-14

issue-link-channel: pr-body-close
  # 轴4。出处：PR 模板头部注释 "Make sure that the pull request corresponds to a
  # GITHUB issue"（.github/PULL_REQUEST_TEMPLATE.md 直读）+ merged PR 标本复测：
  # 近 15 条 merged dev PR 中 5 条正文含 close/fix/resolve #N、12 条正文含任意 #N
  # 引用（API repos/apache/seatunnel/pulls?state=closed，2026-10-14）——社区使用率
  # 高于 A3 考证时的 0/6，但仍是软惯例；[USER] "无 issue 不开 PR"严于社区，本包只记
  # 偏差事实不改写政策。标题中的 issue 号不被 GitHub 解析（g-kernel [MECH]），
  # verified 2026-10-14

ci-carrier: push-direct（push 任意分支即触发完整 CI；intra-fork PR 无 CI 价值）
  # 轴5。出处：build_main.yml on: push: branches: ['**'] 直读（workflow_call
  # backend.yml）+ concurrency group cancel-in-progress，verified 2026-10-14。
  # 观察项（未生效）：open PR #12725 提议 labeler/Build-check 改走 workflow_run
  # 触发——若合并可能改变触发面，重挖时复核

branch-protection: dev = required_approving_review_count: 2 + dismiss_stale_reviews: true
                  + strict: true（→ PR 分支须与 dev 同步方可合并）
  # 轴6。出处：.asf.yaml protected_branches.dev 直读，verified 2026-10-14

# —— 头脑风暴新增 4 维度（总库「主会话已裁」#2，2026-10-13 落位；B3 补全）——

target-branch-backport: 新工作 base = dev；backport 目标 = `<X.Y.Z>-release` 分支；
  成文政策 = 无（grep "backport" .github/ docs/en/ README.md 零命中）；
  实观察形态（B3 收口②，样本 2026-10-14）：
  ① 常态 = **committer 直接 cherry-pick 推入 release 分支**（3.0.0-release 的 PR 数
  = 0，2.3.13-release 仅 4 个 release-prep/revert PR），cherry-pick 保留原标题含
  原 PR 的 `(#N)` 尾缀（如 2.3.13-release 上 `... (#10404)`；作者 Adam Wang/zy/
  yzeng1618 等 committer）；② release-prep 走 PR：`[Release][X.Y.Z] Prepare release
  X.Y.Z`，由 release manager 发起（#10464/#10466 by xiaochen-zhou）；③ 贡献者
  backport PR = 例外形态：开放标本 #12638（base=2.3.13-release，正文 "This PR
  backports ... from commit 2739847410 ... Please confirm whether 2.3.13-release
  is the intended backport target"，2026-10-05 开至今未合）——发起前需与 maintainer
  确认目标分支，不自行假定。是否需新 issue：未见要求（标本用 "Refs #9583" 引原
  issue；[USER] 政策仍要求 issue 起步）
  # 出处：git log upstream/{3.0.0,2.3.13}-release 作者与标题 + API
  # pulls?base=<branch> 计数（3.0.0-release=0、2.3.13-release=6 其中 4 merged）+
  # PR #12638 正文直读，verified 2026-10-14。完整记录另见 manual-research MR-7

pr-update-style: rebase（strict 分支保护迫使 PR 分支与 dev 保持同步；既定纪律 = rebase）
  # 出处：.asf.yaml strict: true 直读，verified 2026-10-14。未见 Pulsar 式"禁
  # rebase"成文政策——D4 场景同业矛盾在本仓的证据态 = strict 强制同步

evidence-types: checklist（PR 模板 Check list 4 组 checkbox + 连接器五件套）+
  license（api/engine 范围改动 → LICENSE + tools/dependencies/known-dependencies.txt）+
  ai-trailer（模板无 AI 段 → [USER] 自愿附加）；benchmark = 未见成文要求
  # 出处：.github/PULL_REQUEST_TEMPLATE.md 直读 + backend.yml dependency-license job
  # （needs.changes，api/engine 过滤集触发）+ known-dependencies.txt 实存，
  # verified 2026-10-14。api 过滤集实测比 A3 记载更宽（seatunnel-api/common/config/
  # core/e2e-common/formats/plugin-discovery/transforms-v2/translation/
  # transform-v2-e2e/pom.xml/workflows/tools/dist——backend.yml changes job
  # check_file_updates.py 调用行直读）

issue-pr-relation: 1:1（正文 close #N）；umbrella 形态 = issue 模板 umbrella.yml
  （title 前缀 "[Umbrella] "、label: umbrella；子任务挂接 `Main Issue: #N`，收尾不
  auto-close 父 issue）；豁免类 = 无（[USER] 2026-10-13 完全不豁免）
  # 出处：issue-link-channel 轴同源 + .github/ISSUE_TEMPLATE/umbrella.yml 直读
  # （name: Umbrella / title: "[Umbrella] " / labels: ["umbrella"]），verified
  # 2026-10-14。社区侧另有"trivial 改动可不建 issue"记载（官网 contribute 指南）
  # ——偏差事实记 manual-research MR-9，[USER] 政策不变

## guardrails
<!-- 项目灾难级护栏（置顶）。〔manual〕条目完整记录见 manual-research，此处为摘要行；
     重挖时标注〔manual〕的行不可删。 -->

- **无 issue 不开 PR**（[USER]，完全不豁免）；落地通道 = PR 正文 `close #N` 关键字
  ——社区 5/15 样本用关键字、12/15 含 #ref（2026-10-14 复测，偏差事实记录，不改写
  [USER] 政策）。〔src: PR 模板注释 + merged PR API 标本，2026-10-14〕
- NEVER push apache/seatunnel 远端（按 URL 识别；本地该远端名恰为 upstream）。
  〔src: g-guardrails + git remote -v 实测，2026-10-14〕
- 标题字面示例：`[Type][Module] Summary`（如 `[Fix][Connector-V2] ...`）；**人工永不
  写 `(#N)` 尾缀**——那是 GitHub squash 自动追加的 PR 号（g-kernel）；社区偶有手写
  `(#issue号)` 于标题的形态（→ dev 上双尾缀 `(#issue) (#PR)`，见 MR-8 偏差记录）——
  我们不做。〔src: 见 title 节，verified 2026-10-14〕
- 分支基点 = `<upstream>/dev`（**不是 master**——本仓工作分支为 dev）。〔src:
  .asf.yaml protected_branches + origin/HEAD，2026-10-14〕
- 连接器 PR 五件套缺一即 CI 红/打回：plugin-mapping.properties、seatunnel-dist/
  pom.xml、.github/workflows/labeler/label-scope-conf.yml、seatunnel-e2e 用例、
  config/plugin_config。〔src: .github/PULL_REQUEST_TEMPLATE.md Check list 段直读
  （5 子项原文链接），2026-10-14〕
- 禁提交被 git 跟踪的 `.class` 文件（backend.yml code-style job 有专项拦截 step）。
  〔src: backend.yml "Check for .class files in git" step 直读，2026-10-14〕
- release 分支全矩阵**常态飘红 = 预期基线**（upstream 同 SHA 同败）——勿误判为自己
  的改动引入；对照 upstream 同 SHA 判定。〔manual〕〔src: A3 三轮考证实测
  （2026-10-13），B3 未重测（无 run 标本采样）；完整记录 MR-5〕

## title
<!-- 标题治理态 = soft-convention（无 CI lint、无合并脚本改写；成文来源 + git log 统计双证）。 -->

- 标准形态：`[Type][Module][/Sub] Summary`——近 100 条 upstream/dev 提交双 tag 占
  **90/100（90%）**（软惯例统计，非强制）。〔src: git log --oneline -100
  upstream/dev（fetch 至 2026-10-13 SHA 25bcc53fd）模式统计，2026-10-14〕
- 成文类型词表（贡献文档版）：PR purpose = `Hotfix` `Feature` `Improve` `Docs`
  `WIP`（WIP → 用 GitHub draft PR）；issue purpose = `Feature` `Bug` `Docs`
  `Discuss`。〔src: docs/en/contribution/coding-guide.md "How To Submit A High
  Quality Pull Request" 节直读，2026-10-14〕
- 统计类型词表（merged 实测版，n=100）：`Fix`(42) `Improve`(17) `Feature`(17)
  `Test`(16) `Docs`(7) `Bug`(1)——`Test` 为高频（A3 版未载），`Hotfix` 本窗口未出现
  但成文档在列。〔src: git log 统计，2026-10-14〕
- Module 统计高频（n=100 双 tag 样本）：`Connector-V2`(52) `Zeta`(9) `Transform-V2`(6)
  `CI`(6) `E2E`(5) `CLI`(5)——`Core` 已降至 1（A3 版高频清单中含 Core）。
  Module 不确定时**省略**（宁缺勿错，全词表约 165 个见 MR-1）。〔src: git log 统计，
  2026-10-14〕
- PR 模板注释示例形态：`[Feature] [component] Title of the pull request`、小修
  `[hotfix] [docs] Fix typo in README.md doc`——模板注释用小写/空格分隔形态，实际
  merged 统计以大写无空格形态为主；跟随最新 merged PR 惯例。〔src:
  .github/PULL_REQUEST_TEMPLATE.md 头部注释直读，2026-10-14〕
- issue 标题同用 tag 形态（标本：`[Bug][Connector-V2][JDBC] ...` #12419、
  `[Bug] [Connector-V2] ...` #12737）。〔src: issues API 直读，2026-10-14〕
- squash-only：PR 标题即最终 commit 标题（scope 扩大须同步改标题与正文）。
  〔src: .asf.yaml + g-kernel，2026-10-14〕
- 反模式：永不模仿 kyuubi 式 `[KYUUBI #N]` 标题前缀（跨仓互斥）；永不手写 `(#N)`
  尾缀。〔src: g-kernel + 计划 §1.1 机制级互反实证，2026-10-14〕

## template
<!-- PR 模板 = .github/PULL_REQUEST_TEMPLATE.md。AI 披露段 = 无。 -->

模板四段：
1. `### Purpose of this pull request` — 目的（模板头注释要求与 GITHUB issue 对应）。
2. `### Does this PR introduce _any_ user-facing change?` — 一切用户可感知变化含文档；
   yes 需说明旧行为与新行为；连接器文档改动遵循 issue #4544 规范。
3. `### How was this patch tested?` — 加了测试则声明；E2E 可参照 connector-cdc-mysql-e2e
   示例；未加测试需说明原因。
4. `### Check list`（checkbox）：新 jar 二进制 → 按 new-license.md 加 License Notice；
   必要时更新文档；必要时更新 incompatible-changes.md；连接器代码 → 五件套 5 子项。
   〔src: .github/PULL_REQUEST_TEMPLATE.md 直读，verified 2026-10-14〕

AI 披露：模板**无 AI 段** → [USER] 政策落地为**正文自愿附加**
`Assisted-by: ZCode:GLM-5.3`（evidence-types.ai-trailer 同源；与 kyuubi 必填段
互斥——跨仓差异点）。

## pre-commit
<!-- 派生自 backend.yml 各 job 的本地可预跑命令（"本地过 ≠ CI 必绿"：CI 跑 Java 8/11 ×
     ubuntu/windows 矩阵）。 -->

- `./mvnw spotless:apply`（CI 对应 `--batch-mode --quiet --no-snapshot-updates clean
  spotless:check`）。〔src: backend.yml code-style job "Check code style" step 直读，
  2026-10-14〕
- `./mvnw -B -T 1 clean test -D"license.skipAddThirdParty"=true -pl
  seatunnel-ci-tools -am --no-snapshot-updates`（CI 对应 "Check code specification"
  step；检查族实存验证：api/{ChineseCharacterCheckTest[中文注释\u4e00-\u9fa5 拦截],
  UTClassNameCheckTest, SerialVersionUIDCheckerTest, ImportClassCheckTest,
  ConnectorOptionCheckTest, SpotlessImportReplacementTest} + file/ 规范族）。
  〔src: backend.yml 直读 + seatunnel-ci-tools/src/test/java/org/apache/seatunnel/api/
  目录列表实测，2026-10-14〕
- `.class` 文件自查：`git ls-files '*.class'` 必须为空。〔src: backend.yml 专项
  step 直读，2026-10-14〕
- 连接器改动 → 五件套（见 guardrails）。〔src: PR 模板 Check list 直读，2026-10-14〕
- api/engine 范围改动 → 更新 LICENSE 及 `tools/dependencies/known-dependencies.txt`
  （api 过滤集见 evidence-types 出处行）。〔src: backend.yml changes job +
  dependency-license job + known-dependencies.txt 实存，2026-10-14〕
- 新文件 ALv2 头（CI: apache/skywalking-eyes license-header job；.licenserc.yaml
  spdx-id: Apache-2.0 / copyright-owner: ASF）。〔src: backend.yml + .licenserc.yaml
  直读，2026-10-14〕

## ci
<!-- 轴5 细节：push-direct 全量流水线 + 快慢门禁分层 + 首贡献批准链 + 飘红基线。 -->

- **push 任意分支即触发完整 CI**：build_main.yml on: push（branches-ignore 仅
  `gh-readonly-queue/**`；另有 workflow_dispatch 手动补跑口——push 事件丢失时从
  fork Actions 页手启，定时 Update-build-status 会把它采纳为 PR 的 Build check）
  → workflow_call backend.yml——**job 键 47 个，矩阵展开后 ~90+ 实例**（IT job ×
  JDK 腿翻倍）；fork 上 push 特性分支 = 事实上的 CI 验证，intra-fork PR 无增量
  价值。〔src: build_main.yml + backend.yml 直读 @ upstream/dev 25bcc53fd + B5
  干跑 fork run 38500181316 job 清单实测，2026-10-14〕
- 快门禁（分钟级反馈环）：License header / Code style（B5 实测：push 后 ~2.5 min
  两门禁 + changes/Dead links/Sanity check/Helm Chart 全绿）；**全量非分钟级**——
  unit-test job 自述 70-88 min（timeout 120 min），代码改动触发定向 IT 时全程
  小时级；**快门禁绿 ≠ 全绿**，PR 状态判读与 ping 时机以此为据。
  〔src: B5 run 实测计时 + backend.yml L599-605 自述注释 @ 25bcc53fd，2026-10-14；
  修正 A3 "~15 min 全量双绿"旧值（37 job 时代计时）〕
- release 分支（`*-release`）跑全矩阵且**常态飘红** = upstream 同 SHA 同败的预期
  基线（见 guardrails）。〔manual〕〔src: A3 考证实测，MR-5〕
- upstream PR 的 Build check = fork run 状态镜像：update_build_status.yml 每 15 min
  cron 把 fork/分支构建状态同步为 PR check。〔src: update_build_status.yml（cron
  "*/15 * * * *"）直读，2026-10-14〕
- 首贡献 CI 待批准门控：approve-label 链——PR review（pull_request_review）→
  Label-when-reviewed（approve-label-trigger.yml）→ workflow_run 触发
  approve-label.yml：committer review 通过打 `approved` label
  （require_committers_approval: true + 缺批自动摘 label），任何人 review 通过打
  `reviewed` label。〔src: approve-label-trigger.yml + approve-label.yml 直读
  （label: 'approved' L53 / label: 'reviewed' L62），2026-10-14〕
- fork Actions 已启用。〔src: A3 考证实测（2026-10-13），2026-10-14 沿用〕
- CI 失败五态分类按 g-kernel 模式 + 本仓基线（release 飘红、规范门禁不可 rerun 救）
  判读。〔src: g-kernel + A3 D5 场景，2026-10-14〕

## filter
<!-- issue 模板形态 + label 一手词汇（禁止跨仓继承——与 kyuubi 词汇表互斥）。 -->

- issue 模板：bug-report.yml / feature-request.yml / umbrella.yml（GitHub forms
  形态）。〔src: .github/ISSUE_TEMPLATE/ 目录直读，2026-10-14〕
- issue label 一手计数（open，API 复测）：`bug`(157)、`good first issue`(23)、
  `help wanted`(112)；`umbrella` 当前 open 计 0。〔src: api.github.com search
  issues 计数，2026-10-14〕
- umbrella issue：title 前缀 `[Umbrella] `、label `umbrella`。〔src: umbrella.yml
  直读，2026-10-14〕
- PR labeler（add-label.yml → labeler/label-scope-conf.yml，路径映射自动打）：
  通用 `CI&CD` `Zeta` `e2e` `document` `flink` `spark` `ZetaRestAPI`（**无空格**
  形态，A3 版记 "Zeta Rest API" 有误）`api` `core` `format` `dependencies`
  `connectors-v2` `transform-v2` + 约 50 个连接器专属 label（amazondynamodb/
  amazonsqs/cassandra/cdc/clickhouse/databend/datahub/dingtalk/doris/druid/
  easysearch/elasticsearch/email/file/google-firestore/google-sheets/graphql/
  hbase/hive/http/prometheus/hudi/iceberg/influxdb/iotdb/jdbc/kafka/maxcompute/
  mongodb/neo4j/openmldb/paimon/pulsar/rabbitmq/redis/rocketmq/s3-redshift/
  selectdb-cloud/sentry/socket/starrocks/tablestore/tdengine/web3j/Milvus/
  activemq/qdrant/typesense/sls/aerospike/sensorsdata/hugegraph…全表见
  label-scope-conf.yml）。〔src: label-scope-conf.yml 键直读（约 60+ 条），
  2026-10-14〕
- CI 批准链 label：`approved`（committer review）/ `reviewed`（任何人）。
  〔src: approve-label.yml 直读，2026-10-14〕
- stale 豁免 label（issue 侧）：`Waiting for reply` `Waiting for code update`
  `Waiting for users feedback` `New feature` `STIP` `security`。〔src: stale.yml
  exempt-issue-labels 直读，2026-10-14〕
- backlog 筛选面（阶段 0.5）：`bug` + `good first issue`/`help wanted` 为主要入口
  词汇；排除含 `[Umbrella]` 标题（starter 任务）。〔src: 上述一手清单 + 总库
  A2/B9，2026-10-14〕

## routing

- 通知地址（.asf.yaml）：commits/issues/pullrequests/pullrequests_status/
  pullrequests_comment 全部 → commits@seatunnel.apache.org。〔src: .asf.yaml
  notifications 段直读，2026-10-14〕
- dev@ 列表：**dev@seatunnel.apache.org（已证实，B3 收口①定稿）**——官网订阅页
  列 dev（"developer holds other general discussions"）/users（"user asks for
  help"）/commits 三列表；官网 contribute 指南："When in doubt, email
  dev@seatunnel.apache.org first"（架构级变更讨论/发版投票/正确性 bug 提请注意）。
  〔src: seatunnel.apache.org/community/contribution_guide/subscribe +
  /community/contribution_guide/contribute（DOAP mailing-list 字段指向订阅页），
  网页抓取，2026-10-14〕
- 提案通道：架构级 / 新 API/SPI 面 → **[STIP] 强烈建议**（"For architectural
  changes or new API/SPI surface, a [STIP] is strongly recommended"）；issue purpose
  词表含 `Discuss`；stale 豁免含 `STIP` label。〔src: 官网 contribute 指南 +
  coding-guide.md + stale.yml，2026-10-14〕
- 问答渠道：users@seatunnel.apache.org（订阅页：user asks for help）。
  〔src: 订阅页，2026-10-14〕
- 安全漏洞（B3 收口①定稿）：**security@apache.org，邮件中注明项目名 SeaTunnel**
  （"specify the project name SeaTunnel with the description of the issue"）+
  提供复现方式；公开披露前必须先报此渠道。**注意：不是
  security@seatunnel.apache.org**（A3 推断地址在官网无记载——错地址 = 漏洞报告
  丢失的不对称风险，本条即为此修正）。仓库无 SECURITY.md（根与 .github/ 均无）。
  〔src: seatunnel.apache.org/security 官网页（curl 抓取实证，security@apache.org
  出现 2 次、security@seatunnel.* 零次），2026-10-14〕

## local
<!-- 派生自 CI 测试矩阵。本地过 ≠ CI 必绿：CI 矩阵 = Java 8/11 × ubuntu/windows。 -->

- 全量单测（CI 同款）：`./mvnw -B -T 1 clean verify -DskipUT=false -DskipIT=true
  -D"license.skipAddThirdParty"=true -D"skip.ui"=true --no-snapshot-updates`。
  〔src: backend.yml unit-test job 直读，2026-10-14〕
- 集成测试（改动模块定向）：`./mvnw -T 1 -B verify -DskipUT=true -DskipIT=false
  ... -pl <it-modules> -am -Pci`——it-modules 由 tools/update_modules_check 按改动
  文件计算（CI 自动化，本地可用同一脚本）。〔src: backend.yml
  updated-modules-integration-test-part-1..8 job + tools/update_modules_check/
  实存直读，2026-10-14〕
- CI 矩阵维度：**java: ['11','17']** × os: ['ubuntu-latest','windows-latest']
  （unit-test）；集成测试 ubuntu-only × 11/17 双 JDK 腿。（B5 修正：原记 ['8','11']
  系 B3 基于落后 1216 提交的本地克隆直读——**挖掘铁律：CI 工件直读须对照 upstream
  最新引用（git show upstream/dev:path 或 fetch 后远端引用）并记基点 SHA**，本地
  克隆可能大幅落后。）〔src: backend.yml L599-601/650-652 strategy.matrix @
  upstream/dev 25bcc53fd，2026-10-14〕

## misc
- release-branch-activity：（R1-4A；B3 收口③复核快照 2026-10-14，采集：fetch 后
  git for-each-ref refs/remotes/upstream/，与 A3 快照逐项比对**全部无变化**）
  3.0.0-release  2026-09-23（活跃：dev 合并流 cherry-pick 持续进线）
  2.3.13-release 2026-02-09
  2.3.12-release 2025-09-05
  2.3.11-release 2025-05-21
  2.3.10-release 2025-03-25
  2.3.9-release  2025-01-12
  2.3.8-release  2024-10-08
  2.3.7-release  2024-08-14
  2.3.6-release  2024-07-26
  2.3.5-release  2024-04-21
  2.3.4-release  2024-02-25
  2.3.3-release  2023-08-18
  2.3.2-release  2023-06-13
  2.3.1-release  2023-03-19
  2.3.0-release  2022-12-23
  2.1.3-release  2022-07-27
  2.1.2-release  2022-06-03
  2.1.1-release  2022-04-18
  （用途：阶段 6 ping 时机前的发版节奏代理判断——release 窗口期 PR 停滞属常态）
- stale：**PR 120 天无活动标记 + 7 天关闭**（days-before-pr-stale: 120,
  days-before-pr-close: 7）；issue stale 禁用（days-before-issue-stale: -1——
  消息文案含 30 天字样但配置值为权威）。〔src: stale.yml 直读，2026-10-14〕
- license 机制：apache/skywalking-eyes@v0.5.0（license-header job）+
  dependency-license job（api/engine 触发，比对 LICENSE 与 known-dependencies.txt）。
  〔src: backend.yml 直读，2026-10-14〕
- fork 同步集快照（2026-10-14 实测）：fork dev 落后 upstream **1216** commits
  （ahead 0）；fork 持有全部 18 个 `*-release` 分支；upstream 杂项分支（非 dev 非
  release）实测 **36** 个（A3 记 35，2026-10-05 新增 fix-rocketmq-* 类）——bot/
  stabilize/revert/davidzollo_*/docs-*/codex/* 等杂项分支**勿同步**。〔src:
  git rev-list --count origin/dev..upstream/dev + for-each-ref 计数，2026-10-14〕
- 分支命名：软惯例观察（B3 补全，A3 记 unknown）——近 50 条 PR head refs 形态：
  `<type>/<slug>`（fix/…、improve/…、feature/…、ci/…、docs/…）与
  `<type>-<issue#>-slug`（fix-12754-doris-ip-types、feature-12357-…）并存，亦有
  `docs-fix-batch-<date>`；无强制。成文惯例 = 无（贡献文档只说 "create a new
  branch"）。〔src: API pulls head.ref 抽样（50 条）+ 官网 contribute 指南，
  2026-10-14；统计性质归 manual 视角，取材可机械重跑故记 mining-misc〕
- 双语文档树：docs/en 与 docs/zh 完全镜像（contribution/ 等目录一一对应）——同步
  政策为软惯例，见 manual-research MR-2。〔src: docs/zh/ 目录结构实测，2026-10-14〕

## manual-research
<!-- regeneration: manual——不可从 CI 工件机械派生；重挖永不覆写本节；存疑条目呈报用户。
     双备份兜底：个人母本 ~/.zcode/rules/seatunnel.md + docs/plan 归档（A3 草案 +
     B3 执行记录）。每条带考证日期与方法。 -->

- **MR-1｜Module 词表高频清单**：模块词全表约 165 个；**B3 复测高频（n=100，
  2026-10-14）**：`Connector-V2`(52) `Zeta`(9) `Transform-V2`(6) `CI`(6) `E2E`(5)
  `CLI`(5)——`Core` 降频至 1、`Transform-V2`/`CLI` 升入高频（A3 版高频含 Core）。
  不确定时省略 tag（宁缺勿错）。软惯例统计，无 workflow 强制。〔src: git log
  --oneline -100 upstream/dev 统计，2026-10-14〕
- **MR-2｜双语文档同步政策**：docs/en + docs/zh 双树镜像存在；文档改动应双语同步为
  软惯例。开 PR 前自查对应语言树是否需同步更新。〔src: docs/zh 目录结构实测 +
  总库 B12 场景 + 近期 docs PR 标本（#12347 "add missing zh" 类），2026-10-14〕
- **MR-3｜标题双 tag 统计基线**：双 tag（[Type][Module]）占比 A3 考证 ~75% →
  **B3 复测 90/100（2026-10-14）**——soft-convention 态证据锚点上移，但仍是统计
  非强制；标题漂移不经 CI 工件变化，事件触发失效永不命中（诚实限制：仅 90 天
  时间兜底）。〔src: git log 统计两轮对比，2026-10-14〕
- **MR-4｜社区 close 关键字使用率**：A3 考证 0/6 → **B3 复测 5/15 正文含 closing
  关键字、12/15 含任意 #N 引用**（近 15 条 merged dev PR，2026-10-14）。社区惯例
  弱于 [USER] "无 issue 不开 PR + 正文 close #N" 的程度已收窄（多数 PR 引用
  issue，约 1/3 用自动关闭关键字）；仍记录为偏差事实呈报用户，不改写政策。
  〔src: API merged PR 正文抽样 n=15，2026-10-14〕
- **MR-5｜release 分支飘红判读经验**：release 分支全矩阵常态飘红（upstream 同 SHA
  同败；A3 记"80-job"，backend.yml 现为 47 job——release 侧实际 job 数以 run 现场
  为准，B3 未重测 run 标本）。判读 CI 结果先对照 upstream 同 SHA 再归因自己。
  〔src: A3 三轮考证实测（2026-10-13）+ backend.yml 现读注记，2026-10-14〕
- **MR-6｜upstream 杂项分支清单**：upstream 55 个分支 = dev + 18 个 `*-release` +
  **36 个杂项**（bot/stabilize/revert/davidzollo_republish_*/docs-*/codex/*/
  agent/*/fix-* 等）——fork 同步白名单 = {dev, *-release}，杂项勿同步。
  〔src: for-each-ref 分类计数（B3 实测 36，A3 记 35），2026-10-14〕
- **MR-7｜backport 形态观察（B3 收口②）**：成文政策无（grep 零命中）；实观察：
  ①常态 = committer 直接 cherry-pick 推 release 分支，保留原标题含原 PR `(#N)`
  （3.0.0-release 的 PR 数=0，2.3.13-release 仅 release-prep/revert PR）；②
  release-prep PR 由 release manager 发起，标题 `[Release][X.Y.Z] Prepare release
  X.Y.Z`，另有 maven-release-plugin 自动提交（"[maven-release-plugin] prepare
  release/next development iteration"）；③贡献者 backport PR = 例外：标本 #12638
  （2026-10-05 开、未合），正文明言 backport 自某 commit 并**请求确认目标分支**——
  贡献者不自行假定 backport 目标。对本仓工作流的含义：新工作 base=dev；需要
  backport 时在原 issue/PR 中与 maintainer 确认目标线，不自行开 release-base PR
  （除非被要求）。〔src: git log 作者/标题 + pulls?base= API 计数 + #12638 正文，
  2026-10-14〕
- **MR-8｜社区标题手写 (#issue号) 偏差**：社区偶在 PR 标题手写 issue 号括号（标本
  #12420 标题含 "(#12419)"、#12738 含 "(#12737)"，二者均为 issue）——squash 再
  追加 PR 号 → dev 上出现 `(#issue) (#PR)` 双尾缀。**我们不效仿**（g-kernel：人工
  永不写 (#N)；issue 关联走正文 close #N）。记录为偏差事实防误读 git log 时以为
  双尾缀都是 backport。〔src: git log + issues API 验证 12419/12737 为 pure
  issue，2026-10-14〕
- **MR-9｜社区 trivial-免-issue 立场 vs [USER] 零豁免**：官网 contribute 指南记载
  trivial 改动（如 "Fix typos in Foo scaladoc"）无需建 issue；[USER] 政策
  （2026-10-13 裁决）严于此——typo/doc/follow-up 一律 issue 起步。偏差事实，
  政策不变；据此在社区侧被 reviewer 质疑"为何 typo 也开 issue"时可引用本条说明
  是个人规范严于社区惯例。〔src: 官网 contribute 指南（网页抓取），2026-10-14〕
- **MR-10｜社区 review/merge 礼仪（官网 contribute 指南）**：LGTM = "看过且如同
  自己所写般担责"；仅 committer 可 merge；committer **不直接 close 被拒 PR**——
  贡献者自行关闭自己的被拒 PR；非 committer 有轻量 triage 角色但不能 merge；
  测试命名可引用 issue 号（`SeaTunnel-12345: a short description` 形态，Scalatest/
  Java 注释）。〔src: 官网 contribute 指南（网页抓取），2026-10-14〕

---

## B3 采集决策注记（2026-10-14，首次执行落盘）

1. **kernel-version**：取 SKILL.md Changelog 当前版本 1.0-draft-2026-10-14（G 层
   文案逐字取自种子模板 templates/rule-pack-template.md）。
2. **安全渠道修正**：A3/计划 §4.2 推断 security@seatunnel.apache.org；B3 官网考证
   定稿 security@apache.org + 注明项目名——一手证据（官网 /security 页）胜出，
   routing 节已按新值落盘。
3. **dev@ 已证实**：A3 记"推断未证实"；B3 经官网订阅页 + contribute 指南双源证实
   dev@seatunnel.apache.org，"未证实"标注解除。
4. **数字更新类**（backend job 37→47、双 tag 75%→90%、close 关键字 0/6→5/15、
   Core 降频/Transform-V2 与 CLI 升频、杂项分支 35→36、fork 落后 1214→1216、
   labeler 键名 Zeta Rest API→ZetaRestAPI、bug 158→157）：均为 B3 现挖一手值
   覆盖 A3 考证值，出处行已更新；两轮统计差异主要来自采样窗口与 workflow 演进。
5. **分支命名 unknown→软惯例观察**：API head.ref 抽样补全（A3 预留的"日后从 PR
   head refs 抽样补充"钩子在本次首采即兑现）。
6. **backport unknown→实观察形态**：target-branch-backport 维度补全 + MR-7 完整
   记录（B3 收口②交付）。
7. **〔manual〕guardrails 行保留**：release 飘红基线条目标注〔manual〕（MR-5），
   重挖不删。
