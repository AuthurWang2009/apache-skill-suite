# apache-skill-suite

Apache 软件基金会（ASF）通用贡献工作流 skill 套件，可一键部署到 ZCode、Claude CLI、
Kimi Code 三类 AI 编码代理环境。

## 套件组成（3 个 skill）

| Skill | 职责 |
|---|---|
| `apache-commit-pr` | commit / PR 时点规范内核：远端识别、标题模板框架、门禁框架、PR 模板、CI 解读、ASF 合规自检、硬护栏（无 issue 不开 PR、批准门控、AI 披露、永不 push 官方远端） |
| `apache-dev-workflow` | 端到端贡献编排：issue 画像匹配 → 分支 → 本地验证 → fork 侧 CI → upstream PR → review 迭代 → merge/withdraw 决策 |
| `apache-sync-fork` | fork ↔ upstream 分支同步：只读诊断四分类（MISSING / FORK-ONLY / DIVERGED / STALE）、ff-only 推 fork、删除 stale 分支（每步显式批准） |

三者共读同一规则包（`<repo>/.zcode/rules/<project>.md`，单一事实来源）。仓库特定
事实（标题格式、默认分支、门禁命令等）全部来自规则包，正文零仓库规则——cache miss
时按内联挖掘程序当场从仓库现读。

另附 `rules/`：G 层规则包母本（seatunnel、dolphinscheduler），可选用
`install.sh --with-rules` 装入 `~/.zcode/rules/`。

## 安装

```bash
git clone git@github.com:AuthurWang2009/apache-skill-suite.git
cd apache-skill-suite

./install.sh                        # 自动检测已装环境（zcode/claude/kimi）并部署
./install.sh --target zcode,claude  # 只部署到指定环境
./install.sh --symlink              # 软链（repo 即唯一事实来源，git pull 即更新）
./install.sh --with-rules           # 同时安装 G 层规则包母本到 ~/.zcode/rules/
./uninstall.sh                      # 卸载（只删三个具名目录，无通配）
```

各环境的安装位置：

| 环境 | 位置 |
|---|---|
| ZCode | `~/.zcode/skills/<skill>/SKILL.md` |
| Claude CLI | `~/.claude/skills/<skill>/SKILL.md` |
| Kimi Code | `~/.kimi/skills/<skill>/SKILL.md`（用户级自动发现目录） |

## 跨环境注意事项

- skill 正文中的模板/母本路径硬编码为 `~/.zcode/skills/...` 与 `~/.zcode/rules/...`
  （zcode 为原生环境）。在本机三环境共存时这些路径物理存在、行为一致；在无 ZCode
  的机器上 kimi / claude 仍可运行，母本缺失时 skill 内置回退程序生效。
- 项目级旧形态 skill 让渡（如 kyuubi 仓内 `.zcode/skills/kyuubi-*`）以各环境的
  技能发现列表为判定基准：ZCode 会发现 `.zcode/skills/` 项目级 skill 并让渡；
  Claude / Kimi 只发现自己路径约定（`.claude/skills/`、`.kimi/skills/`）下的项目
  skill，仓内 `.zcode/skills/` 旧 skill 对其不可见，让渡条款不触发，按通用程序
  走内联挖掘——结果等价（不借规则、不猜），路径不同。

## B4 触发矩阵验证

`tests/b4-matrix.sh` 以无头只读模式（三环境统一 plan mode）复跑 7 格触发矩阵：

```bash
./tests/b4-matrix.sh zcode    # 或 claude / kimi
```

矩阵定义与判定标准见 `docs/b4-matrix.md`，历次结果见 `docs/results/`。

## 版本

- 2026-10-14：三 skill 定稿（v2.19，apache-sync-fork 由 sync-fork 更名统一前缀），
  首次入库并完成三环境部署验证。
