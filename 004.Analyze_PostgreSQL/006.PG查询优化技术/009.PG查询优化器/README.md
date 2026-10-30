# 009.PG查询优化器

基于 **PostgreSQL 18.6** 源码（`000.SOURCE_CODE/002.PostgreSQL-18.6/postgresql-18.6`）的查询优化器分析笔记。所有函数行号均已在 18.6 源码中核实。

## 文档清单

| 文件 | 内容 |
|---|---|
| [000.Postgresql-查询优化器总览.md](000.Postgresql-查询优化器总览.md) | 优化器在 SQL 执行流程中的位置、Path/Plan 分离设计、核心数据结构、代价模型、与 MySQL 优化器对照 |
| [001.Postgresql-优化器处理流程.md](001.Postgresql-优化器处理流程.md) | 三大阶段逐步展开：预处理（逻辑优化）→ 路径搜索（物理优化）→ 计划生成，含精确到行号的调用链 |
| [002.Postgresql-优化器源码介绍.md](002.Postgresql-优化器源码介绍.md) | `src/backend/optimizer/` 五个子目录（plan/path/prep/util/geqo）逐文件导读：职责 + 关键函数 + 行号 |
| [003.Postgresql-优化器流程图集.md](003.Postgresql-优化器流程图集.md) | 11 张 ASCII 流程图：总体流水线、预处理、DP 连接搜索、GEQO、三族连接路径、add_path 竞争、Path→Plan 转换、代价模型速记 |
| [004.Postgresql-等值范围估算与eq_range_index_dive_limit.md](004.Postgresql-等值范围估算与eq_range_index_dive_limit.md) | PG 有没有 MySQL `eq_range_index_dive_limit` 的对应物：IN 列表估算路径（scalararraysel）、精度天花板 statistics_target、无统计兜底 0.5%、哈希化 SAOP 阈值 9、计划期唯一"索引下潜" get_actual_variable_range |
| [005.Postgresql-优化器如何选择索引.md](005.Postgresql-优化器如何选择索引.md) | 索引选择的五步漏斗：条件匹配（indxpath.c 匹配链）→ 四类路径生成（含 Bitmap AND/OR）→ 参数化路径 → cost_index 解剖（correlation/缓存折算/allvisfrac）→ add_path 竞争与 enable_* 罚分 |

## 一句话总结

```text
 planner() 三步走:
   ① 逻辑重写: 把 Query 拍平变好优化 (子查询上拉/外连接消除/常量折叠/条件规范化)
   ② 路径搜索: 动态规划(表≥12切遗传算法)枚举 连接顺序×扫描方式×物理算子,
      每层用代价模型(页I/O + CPU)竞争, 只留 Pareto 最优 Path
   ③ 计划生成: 最优 Path → Plan, 变量引用回写修正, 交给执行器
```

## 上级目录

- 返回 [../000.Postgresql-总览-MySQL优化技术坐标.md](../000.Postgresql-总览-MySQL优化技术坐标.md)
