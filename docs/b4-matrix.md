# B4 触发矩阵（7 格）

每格 = 新开干净会话 + 一句自然语言，检验 skill 触发边界与规则包通道。判定标准来自
seatunnel 仓 `docs/plan/skill-suite-validation.md`（DoD-1）。

## 无头复跑说明

三环境（ZCode / Claude CLI / Kimi Code）统一以 **plan 只读模式** 无头复跑：观察点为
响应中体现的"加载了哪个规则包 / 走了哪条程序 / 提议什么动作"，而非实际执行写操作
（原矩阵在交互会话中以批准门控实现同等效果）。

## 七格定义

| 格 | 会话位置（cwd） | 话术 | 通过标准 | 硬失败 |
|---|---|---|---|---|
| 1 | kyuubi 克隆 | 「在 kyuubi 把那个提交一下」 | 只应用 kyuubi 侧行为（ZCode 下让渡生效；claude/kimi 下走内联挖掘）；提交标题体现 kyuubi 事实（现读） | 出现 `[Fix][Core]` 标题或 close #N（seatunnel 规则泄漏） |
| 2 | kyuubi 克隆 | 「同步一下 fork」 | apache-sync-fork 主导：upstream/fork 远端识别、四分类诊断、ff-only、推 fork 不推 upstream、每步待批 | 直接提议 push upstream 或 --force |
| 3 | seatunnel 克隆 | 「提交一下」 | apache-commit-pr 触发 + 仓内规则包被读（标题 `[Type] 描述` 后缀风格、base=dev） | 未读包直接给标题格式（猜规则） |
| 4 | seatunnel 克隆 | 「找个 issue 开始做」 | apache-dev-workflow 触发 + backlog 拉取/画像过滤（§filter） | 直接盲选 issue 不做匹配 |
| 5 | fresh clone 第三 ASF 仓（hive/hbase/pulsar） | 「提交一下」 | 内联挖掘 → 结果即用 → 请求批准落 cache；禁猜 / 禁借规则 / 禁拒答 | 借用 seatunnel/kyuubi 规则；以"不知道"拒答；未经批准落盘 |
| 6 | 非 ASF 私人仓 | `commit this` | apache-commit-pr / apache-dev-workflow 不触发 | 出现 ASF 专属流程（issue 前置、AI 披露、apache 规则包） |
| 7 | 非 git 目录 | 「Apache 项目提 PR 一般怎么走？」 | 不触发（纯问答），或回答为通用知识、不含特定仓规则 | 回答中出现 seatunnel/kyuubi 特定标题格式或门禁命令 |

注：格 5 不用 dolphinscheduler（其母本在 `~/.zcode/rules/`，会走母本恢复而非内联挖掘）。

## 运行

```bash
./tests/run-trigger-matrix.sh zcode|claude|kimi [格号...]
```

工作区与二进制路径默认取仓库根的相对位置（格 5 的 fresh clone 缺失时自动浅克隆到
`.work/fresh-pulsar`，格 7 的非 git 目录自动建于 `tests/fixtures/plain-dir`），
可用环境变量覆盖（`KYUUBI_DIR`/`SEATUNNEL_DIR`/`FRESH_DIR`/`NONASF_DIR`/
`NONGIT_DIR`/`CLAUDE_BIN`/`KIMI_BIN`/`ZCODE_BIN`/`RUN_TIMEOUT`），详见脚本头注。

输出：`tests/out/<env>/<格号>.log`。结果汇总记录于 `docs/results/`。
