# Rule pack: dolphinscheduler
<!-- 单一事实来源：apache-commit-pr / apache-dev-workflow / 文档三消费方共读。
     位置：<repo-root>/.zcode/rules/dolphinscheduler.md（gitignored 工作副本）
     + ~/.zcode/rules/dolphinscheduler.md（个人母本，双层持久化）。
     B4 bootstrap 注记（2026-10-14）：本包由内联挖掘程序对 apache/dolphinscheduler dev 分支
     （浅克隆 /tmp/ds-bootstrap + 匿名 API）现场派生；按 R4 共识本期仅落个人母本，
     仓内工作副本未创建。 -->

schema-version: 1
kernel-version: 1.0-draft-2026-10-14   <!-- 信息性：G 层生成来源（skill Changelog 当前版本） -->
verified: 2026-10-14

# ===== Layer G：通用规则层（generated, read-only）=====
<!-- 本层由种子模板机械再生（模板 ~/.zcode/skills/apache-dev-workflow/templates/rule-pack-template.md），
     禁手改；skill 正文永远权威。G 层不含任何项目事实。 -->

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
- [ASF][USER] 永不 push 官方远端（apache/dolphinscheduler，无论远端名）：PR-first 贡献流，
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
- [MECH] 上游识别是程序不是常量：远端 URL 对照（github.com/apache/dolphinscheduler
  快路径已命中）→ fork 血缘 API → 归属判断（apache 组织 + .asf.yaml 存在 → ASF 合规清单）。
- [ASF] issue 礼仪默认值：先搜后建、评论认领（"taking this"；非 committer 不能
  self-assign）；仓内有更具体礼仪时以 P 层 filter 与 routing 节为准。
- [ASF] ICLA 政策框架：偶尔 PR 无需 ICLA（ALv2 clause 5）；持续实质贡献/committer
  提名前签署（个人邮箱，与 git config 邮箱一致）。

# ===== Layer P：项目 CI/CD 规则缓存（2026-10-14 首次挖掘）=====

upstream: https://github.com/apache/dolphinscheduler      <!-- git remote -v（/tmp/ds-bootstrap 浅克隆），2026-10-14 -->
default-branch: dev                                       <!-- 三源确认：API default_branch=dev + .asf.yaml protected_branches 唯一键 dev + clone HEAD=dev，2026-10-14 -->
release-branch-pattern: [0-9]+.[0-9]+.[0-9]+-release（+ 同形 -prepare 阶梯分支）  <!-- backend.yml/e2e.yml push 触发器 patterns + branches API 实存 29 条（2.0.7-release→3.4.3-release）+ docs/docs/en/contribute/release.md:178/219，2026-10-14 -->
merge-governance: squash-only（.asf.yaml merge/rebase=false）+ 标题治理态=ci-lint（boring-cyborg "Title Validator" status check，挂保护分支 contexts）  <!-- .asf.yaml:34-37 + .github/boring-cyborg.yml:37-51 + .asf.yaml:52，2026-10-14 -->
issue-link-channel: title-prefix（PR 标题 `[Type-IssueNo]` 携带 issue 号，CI 强制）；issue 自动关闭走 commit footer/正文 `Closes #N`  <!-- boring-cyborg.yml:21-33 insertIssueLinkInPrDescription（按标题插 issue 链接）+ commit-message.md:49 "Closes #1234 to auto-close"，2026-10-14 -->
ci-carrier: upstream-pr（核心 workflow 全部 pull_request 触发；push 触发仅 dev/X.Y.Z-prepare/X.Y.Z-release——功能分支 push 不触发任何 CI）  <!-- backend.yml/unit-test.yml/frontend.yml/docs.yml/e2e*.yaml 触发器读毕，2026-10-14 -->
branch-protection: 1 个 approving review + dismiss_stale_reviews=true + strict=true（合并前分支必须与 dev 同步）  <!-- .asf.yaml:38-55 protected_branches.dev，2026-10-14 -->

target-branch-backport: 新工作 base=dev；backport 社区侧存在 `release cherry-pick` label（label 清单一手）+ release.md 发版流程（release 分支基于 prepare 分支创建）——贡献者 PR 侧 backport 操作惯例未成文，记 unknown（取材尝试：pull-request.md/commit-message.md/release.md 均无贡献者 backport 指引；merged PR 标本未见 backport 形态标题）  <!-- label API + docs/docs/en/contribute/release.md，2026-10-14 -->
pr-update-style: 未成文（无 rebase/merge 明文纪律）；硬约束来自 strict=true——PR 分支必须 up-to-date with dev 才可合并，rebase onto dev 或 merge dev into 分支皆可满足，无项目强制择一  <!-- .asf.yaml:41 strict 注释 + 贡献文档检索无果，2026-10-14 -->
evidence-types: {ai-trailer（模板自带 AI 段，填入该段）, test-justification（Verify this pull request 四选一）, license（新文件 ALv2 头 skywalking-eyes 门禁 + 依赖 LICENSE 检查）, checklist（不兼容变更须记 docs/docs/en/guide/upgrade/incompatible.md）}  <!-- PULL_REQUEST_TEMPLATE.md 全文 + sanity-check action + backend.yml:95 check-LICENSE.sh + PR 模板末行，2026-10-14 -->
issue-pr-relation: 1:1（"each Pull Request is submitted should be associated with only one issue"；多 issue 场景官方指引=拆 sub-task issues 挂同一父 issue，每 PR 对一个 sub-task）；豁免类=无（[USER] 政策，P 层不得改写；**偏差事实呈报**：社区 commit-message.md:26-28 明文 `Chore` 类不要求 issue ID——社区允许 Chore 无 issue，与 [USER] 无 issue 不开 PR 冲突，执行时按 [USER] 从 issue 起步，可考虑以 chore 类 issue 起步）  <!-- pull-request.md:93-100 + commit-message.md:19-28，2026-10-14 -->

## guardrails
<!-- 项目灾难级护栏（置顶）。灾难条目自 title/ci/misc 各节上提。 -->

- 标题不合规 = Title Validator status check 直接红：PR 标题必须匹配
  `^\[DSIP-[0-9]+\]|^\[Feature-[0-9]+\]|^\[Fix-[0-9]+\]|^\[Doc-[0-9]+\]|^\[Improvement-[0-9]+\]|^\[Test-[0-9]+\]|^\[E2E-[0-9]+\]|^\[CI\]|^\[Chore\]`
  （`[CI]`/`[Chore]` 免 issue 号，其余类型必带 issue 号）。出处：.github/boring-cyborg.yml:39 titleRegexp，2026-10-14。
- PR 必须由 maintainer 设 milestone + 至少一个有效 label（feature/bug/improvement/document/chore/DSIP/CI&CD/revert），否则 Mergeable status check 红——贡献者无法自设 milestone，此为流程性等待项非失败。出处：.github/workflows/mergeable.yml:44-64，2026-10-14。
- 永不手写 `(#N)` 尾缀——squash 合并自动追加 PR 号（60 条 commit 标本全部带 (#PR号) 尾缀佐证）。出处：API commits?per_page=60 标本，2026-10-14。
- 不兼容变更（RPC/DB schema/公共 API）必须：commit footer `BREAKING CHANGE: <描述>` + 记入 docs/docs/en/guide/upgrade/incompatible.md。出处：commit-message.md:48 + PULL_REQUEST_TEMPLATE.md:41，2026-10-14。
- 分支基点 = dev（唯一保护分支；勿基于 release 分支开新功能 PR）。出处：.asf.yaml:38，2026-10-14。
- spotless 是规范门禁（不可 rerun 救）：CI 跑 `./mvnw spotless:check`，本地必须先 `./mvnw spotless:apply`（覆盖 Java + pom.xml + Markdown）。出处：.github/actions/sanity-check/action.yml + pull-request.md:85-87，2026-10-14。

## title
<!-- ci-lint 态（Title Validator 强制）+ 官方文档 + 60 commit/24 merged PR 标本三重印证。 -->

- **PR/commit 标题格式**：`[Type-IssueNo][ModuleName] Description`
  - Type ∈ {Feature, Improvement, Fix, Doc, DSIP, Test, E2E, CI, Chore}；除 `CI`/`Chore` 外必带 issue 号（`Feature`↔issue 类型 Feature，`Fix`↔issue 类型 Bug，映射表见 pull-request.md:17-67）。出处：commit-message.md:7-28 + boring-cyborg.yml:39。
  - `[ModuleName]` 选填（commit-message.md:30-32；Title Validator 正则不要求）；真实模块名如 Master/Worker/API/UI/TaskPlugin/DAO/Alert/Registry/Common/Storage-OSS/Helm/E2E/CI。跨切面改动可省略。出处：commit-message.md:32 + 60 commit 标本实测。
  - Subject：祈使语气、说目的不说实现、无句号、≤72 字符。出处：commit-message.md:35-40。
  - 反模式（官方 Avoid 清单）：`fix bug`（无前缀）、`[fix] update master`（错误大小写+缺 issue 号）、一条 commit 塞多个不相关改动。出处：commit-message.md:79-83。
- **issue 标题格式**（与 PR 标题不同）：`[IssueType][ModuleName] Description`，IssueType ∈ {Feature, Bug, Improvement, ...}；例 `[Feature][api] Add xxx api in xxx controller`。出处：docs/docs/en/contribute/join/issue.md Specification 表格，2026-10-14。
- **(#N) 尾缀**：squash 自动追加 PR 号，人工永不写。merged commit 标本形如 `[Improvement-18684][TaskPlugin] Trim whitespace ... (#18685)`——前缀号=issue 18684，尾缀号=PR 18685（两号不同互证）。出处：API commits 标本 #18685 行，2026-10-14。
- 已观察松散变体（勿模仿）：`[Fix-17854] [Worker&SQL Task]`（括号间多空格）、模块大小写不一（`[api]`）、省略模块括号。CI 只验前缀不验模块括号。出处：API commits 标本，2026-10-14。

## template
<!-- PR 模板段清单（.github/PULL_REQUEST_TEMPLATE.md 现读，2026-10-14）。 -->

- `## Was this PR generated or assisted by AI?`——**模板自带 AI 披露段**：答 YES/NO，YES 需注明哪些部分由 AI 生成/辅助。→ [USER] AI 披露政策落点=填入此段（YES + 模型说明），替代自愿附加。
- `## Purpose of the pull request`（必填：这个 PR 做什么）。
- `## Brief change log`（要点 bullet）。
- `## Verify this pull request`（四选一：无测试覆盖的清理 / 已有测试覆盖+描述 / 新增测试+验证步骤 / 空）——test-justification 证据落点。
- `## Pull Request Notice`（指向 pull-request.md 的固定链接段）。
- 末行提示：含不兼容变更须另记 docs/docs/en/guide/upgrade/incompatible.md。
- 模板无 assignee/checklist 复选项、无 benchmark 段。

## pre-commit
<!-- 门禁清单（CI steps 中本地可预跑命令；每条注明 workflow 出处）。 -->

1. `./mvnw spotless:apply`（Java+pom.xml+Markdown 格式化；CI 检查 = `./mvnw spotless:check`）。出处：sanity-check action（backend/unit-test/frontend workflow 共用快门禁）+ docs.yml:41 + development-environment-setup.md:34-40，2026-10-14。
2. 新文件 ALv2 许可证头（CI = apache/skywalking-eyes/header@main）。出处：.github/actions/sanity-check/action.yml Check License Header step，2026-10-14。
3. 涉及依赖变更时：`tools/dependencies/check-LICENSE.sh`（CI 在 Build job 后跑）。出处：backend.yml:94-95，2026-10-14。
4. 前端改动：`cd dolphinscheduler-ui && pnpm install && pnpm run lint`（CI 以 lint 后 git status 是否产生修改判定通过；`pnpm run lint` 本身即 fix）。出处：frontend.yml Code Format Check step + development-environment-setup.md:57-59，2026-10-14。
5. 可选本地钩子：仓库提供 `.pre-commit-config.yaml`（python pre-commit 框架）。出处：development-environment-setup.md:42-44，2026-10-14。
6. 仓库还提供 `pre-commit`（git hooks）以外的 helm docs 校验：改 deploy/chart 时 `./mvnw validate -P helm-doc -pl :dolphinscheduler`。出处：development-environment-setup.md:90，2026-10-14。

## ci
<!-- CI 门禁构成 + 载体 + 礼仪。 -->

- **载体**：全部核心 workflow（Backend/Test(UT)/Frontend/Docs/E2E/API-Test/CodeQL）`pull_request` 触发；`push` 触发仅 dev / X.Y.Z-prepare / X.Y.Z-release。功能分支 push 到 fork **不触发任何 CI** → fork 侧无暂存 CI，阶段 4 直接退化"暂存完成→提请进阶段 5"（upstream-pr 形态）。出处：各 workflow `on:` 块，2026-10-14。
- **pull_request（非 _target）无 secrets 依赖**（仅 GITHUB_TOKEN）：首贡献 PR CI 直接跑，**无 approve-label 等待态**；`pull_request_target` 仅用于 labeler/auto-assign 机器人（pull-request-target-robot.yml），不 gate。出处：workflows secrets 检索（backend/unit-test/docs 无外部 secrets），2026-10-14。
- **status checks（保护分支要求，.asf.yaml contexts）**：Build / Unit Test / E2E / Docs / Frontend Build / E2E-K8S-Result / API-Test-Result / Mergeable: milestone-label-check / Title Validator。
- **paths-filter**：docs-only 改动（`!(docs/**)` 不匹配）跳过 Backend/UT/Frontend，走 docs.yml（仅 `./mvnw spotless:check`）——文档 PR 门禁极轻。出处：backend.yml/unit-test.yml paths-filter job + docs.yml，2026-10-14。
- **快门禁**：sanity-check（license 头 + spotless:check）+ Mergeable + Title Validator（分钟级）；重门禁 = per-module Unit-Test 矩阵 + cluster-test ×4（mysql/postgresql × zk/mysql-registry/pg-registry）+ schema-check ×3 版本 + E2E/E2E-K8S/API-Test。出处：unit-test.yml generate-matrix/job 拓扑 + backend.yml cluster-test/schema-check，2026-10-14。
- **流程性等待项**（非失败）：milestone 与 type label 由 maintainer 设置（Mergeable 红 = 提示用户礼貌请求 maintainer 设 milestone/label，勿当回归返工）。出处：mergeable.yml 失败文案 "A maintainer needs to set ..."，2026-10-14。
- 机器人：boring-cyborg（title 验证 + labeler + 首次 PR 欢迎）；issue-robot（issue 标题/正文自动翻译为英文 + 致谢评论——中文 issue 会被自动翻译，可用中文提 issue 但推荐英文）；pull-request-target-robot（PR labeler + auto-assign reviewers）。出处：boring-cyborg.yml + issue-robot.yml + pull-request-target-robot.yml，2026-10-14。

## filter
<!-- issue 模板形态 + label 一手清单（阶段 0.5 backlog 消费）。 -->

- **issue 模板（forms，.yml）**：bug-report / feature-request / improvement-report / document / dsip-request + config.yml（blank_issues_enabled=false；问答改道 discussions）。bug-report 含 version 下拉（dev / 3.3.0-alpha / 3.3.1 / ...）。
- **label 一手清单**（API repos/apache/dolphinscheduler/labels，2026-10-14 拉取，58 个）——筛选面词汇：
  - 类型：bug / feature / improvement / document / chore / DSIP / enhancement / refactor / duplicate / question
  - 难度/招募：good first issue / help wanted
  - 优先级：priority:low / priority:middle / priority:high
  - 区域：backend / UI / e2e / test / kubernetes / docker / plug-in / development / metrics / arch-arm64
  - 流程：first time contributor / ready-to-merge / ready-to-close / reconsider-later / don't merge / release cherry-pick / incompatible / dependencies / community / gsoc / ospp
  - 检查提醒：miss:docs / miss:tests / miss:ui / check:docs / check:tests
  - stale 豁免（stale.yml:26）：Waiting for reply / DSIP / security / roadmap / help wanted / good first issue / community / priority:*
- **PR label（mergeable 有效性集）**：feature / bug / improvement / document / chore / DSIP / CI&CD / revert（maintainer 或 labeler 打，PR 必须至少其一）。出处：mergeable.yml:56。
- PR labeler 路径映射（自动打）：backend=源码模块、document=docs/**|**/*.md、CI&CD=.github/**、docker=deploy/docker/**、UI=dolphinscheduler-ui/**、e2e、test=**/test/**、kubernetes。出处：.github/actions/labeler/labeler.yml，2026-10-14。
- stale：issue 30 天 stale/7 天 close；PR 120 天 stale/7 天 close。出处：stale.yml:22-38，2026-10-14。

## routing
<!-- 渠道地址（全部一手）。 -->

- 通知/commit 邮件：commits@dolphinscheduler.apache.org（.asf.yaml notifications: commits/issues/pullrequests/discussions 全部指向它，2026-10-14）。
- 开发讨论列表：dev@dolphinscheduler.apache.org（docs/docs/en/contribute/join/subscribe.md，订阅流程在同文，2026-10-14）。
- 问答/支持：GitHub Discussions（.asf.yaml features.discussions=true + ISSUE_TEMPLATE/config.yml contact_links 指向 github.com/apache/dolphinscheduler/discussions/，2026-10-14）。
- **安全漏洞：security@dolphinscheduler.apache.org**（docs/docs/en/contribute/join/security.md 明文：先邮件后公开，邮件注明项目名 DolphinScheduler + 复现步骤建议；已证实，非推断，2026-10-14）。
- 提案通道：DSIP 流程（issue 打 DSIP label + dsip-request.yml 模板；PR 用 `[DSIP-<issue号>]` 标题类型）。出处：issue 模板 + boring-cyborg 正则 + label 清单，2026-10-14。

## local
<!-- 构建/测试命令与矩阵。 -->

- 后端全量构建：`./mvnw clean install -Prelease -Dmaven.test.skip=true`（CI 用 -Pstaging）。出处：development-environment-setup.md:30 + backend.yml:86-90，2026-10-14。
- 单模块测试（CI 等价形态）：`./mvnw verify -pl <module> -DskipUT=false -Dsurefire.printSummary=true`（CI 为 module × java 8/11 全矩阵，模块清单从根 pom <modules> 动态生成，排除 bom/dist/microbench/ui）。出处：unit-test.yml:100-165，2026-10-14。
- 前端：`cd dolphinscheduler-ui && pnpm install && pnpm run build:prod`（CI 跑 ubuntu+macos 双 OS）。出处：frontend.yml，2026-10-14。
- **"本地过 ≠ CI 必绿"矩阵维度**：Java 8/11 × 全模块 ×（cluster-test）DB mysql/postgresql × registry zookeeper/mysql/postgresql ×（schema-check）3.1.9/3.2.0/3.3.1 三版本 × 前端 ubuntu/macos × E2E/E2E-K8S/API-Test。出处：各 workflow strategy.matrix，2026-10-14。
- Java 版本：8 与 11 双支持（后端矩阵）——本地至少跑一个，注意 API 兼容性以 8 为底线（cluster-test/schema-check 均在 JDK8 产物上跑）。出处：backend.yml matrix.java + binary-package-8，2026-10-14。

## misc
- **分支命名**：`Pull Request type`-`Issue number`，如 `Feature-3333`（成文惯例）。出处：pull-request.md:71-73，2026-10-14。
- **release-branch-activity**（R1-4A ping 前发版节奏代理）：29 条 release 分支实存（2.0.7-release → 3.4.3-release，branches API 2026-10-14）；dev 当前 milestone=3.5.0（merged PR 标本 24/24 带 milestone，绝大多数 3.5.0）——3.5.0 发版窗口期 PR 停滞属常态，勿误判被忽视。出处：branches API + pulls API 标本，2026-10-14。
- milestone 机制：版本号命名（3.5.0/3.4.1），maintainer 设定，Mergeable 强制存在。出处：mergeable.yml + merged PR 标本，2026-10-14。
- 版本流：dev 上 "[Chore] Update next release version to 3.4.3"→"[Chore] Add new version 3.4.3"→发版建 `<X.Y.Z>-prepare`→release 分支。出处：commits API 标本 + release.md:219，2026-10-14。
- license 机制：skywalking-eyes header 检查 + tools/dependencies/check-LICENSE.sh 依赖清单检查。出处：sanity-check action + backend.yml，2026-10-14。
- stale 配置：见 §filter（issue 30d/7d，PR 120d/7d）。
- 构建加速：CI 缓存 Maven wrapper（~/.m2/wrapper）与 ~/.m2/repository——本地复跑可预热。出处：backend.yml cache steps，2026-10-14。

## manual-research
<!-- 人工考证条目（regeneration: manual；重挖永不覆写）。 -->

- 〔manual 2026-10-14〕**boring-cyborg issue-link 插入器疑似失修**：`descriptionIssuePlaceholderRegexp: "^fix: (.*)$"` 与实际标题格式（`[Fix-N]`）不匹配，且其 `descriptionIssueLink` 模板 URL 拼写为 `apache/dolphinschedule`（少 "r"）——即使触发也会生成死链。结论：不要依赖 bot 自动插 issue 链接，自己在 PR 正文写 `Closes #N`。考证方法：boring-cyborg.yml:21-33 逐行读 + 正则手工匹配标题标本。
- 〔manual 2026-10-14〕**merged PR 标本观察**：24/24 带 milestone（Mergeable 门禁实际生效）；type label 与标题 Type 大体一致；`first time contributor` label 由机器人打（首贡献者 PR 上普遍出现）。考证方法：pulls API state=closed&merged 过滤 24 条逐条核。
- 〔manual 2026-10-14〕**社区 Chore 无 issue 惯例 vs [USER] 政策的偏差事实**：commit-message.md:26-28 明文"Every type except Chore must carry an Issue ID"，且 60 条 commit 标本中 `[Chore]`/`[CI]` 类约 8 条不带 issue 号（例 "[Chore] Fix quay.io/minio/minio is no longer public in CI"）。P 层仅记录该偏差；执行按 [USER] 无 issue 不开 PR（chore 类工作也先开 issue，哪怕轻量）。
