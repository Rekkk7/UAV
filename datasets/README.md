# UAV 固定种子基准数据集

本目录保存原 MATLAB 实验使用的 **81 个输入算例**。每个规模有 9 种“目标数 × 无人机数”配置，每种配置生成 3 个固定算例，共 27 个配置、81 个 MAT 文件。数据是算法输入，不是算法求解结果。

| 文件夹 | 目标数 | 无人机数 | 配置数 | 每配置算例数 | MAT 文件数 |
| --- | --- | --- | --- | --- | --- |
| 小规模 | 4、8、10 | 2、4、6 | 9 | 3 | 27 |
| 中规模 | 20、40、50 | 10、15、20 | 9 | 3 | 27 |
| 大规模 | 60、80、100 | 30、40、50 | 9 | 3 | 27 |

每行的目标数和无人机数取全部笛卡尔积组合。任务数为目标数的 2 倍，每个目标具有两个顺序阶段。

## 加载数据

从项目根目录执行：

```matlab
addpath(fullfile(pwd, 'datasets'));
data = load_uav_instance('Small-Scale', 4, 2, 1);
% 也支持中文规模名：
data = load_uav_instance('小规模', 4, 2, 1);
```

文件名中的 `T` 为目标数、`U` 为无人机数、`R` 为第几个算例：

```text
小规模/S_T004_U002_R01.mat
中规模/M_T020_U010_R01.mat
大规模/L_T060_U030_R01.mat
```

每个 MAT 文件的变量位于顶层，也可以直接加载：

```matlab
data = load(fullfile('datasets', '小规模', 'S_T004_U002_R01.mat'));
```

实验接入时，将 `num_runs_per_instance` 设为 `3`，通过 `load_uav_instance(scale_name, Target_num, UAV_num, run)` 读取数据，再从返回结构体取出各输入字段。同一配置的同一个 `run` 在不同实验版本中使用相同输入，无需在求解过程中生成新场景。

## 种子与复现

- 基础种子：`20261020`。
- MATLAB 随机数算法：`twister`。
- 每个算例独立设置种子：

```text
seed = 20261020 + scale_index * 10000 + instance_index * 100 + run_index
```

`scale_index` 为 1（小）、2（中）、3（大）；`instance_index` 为 1 至 9，按目标数升序、再按无人机数升序排列；`run_index` 为 1 至 3。完整文件名、配置和种子见 [manifest.json](manifest.json)。

重新生成全部数据：

```matlab
addpath(fullfile(pwd, 'datasets'));
generate_uav_datasets();
```

重新生成单个算例，或核验已有文件：

```matlab
saved = load_uav_instance('Small-Scale', 4, 2, 1);
rebuilt = create_uav_instance('Small-Scale', 4, 2, 1, saved.base_seed);
assert(isequaln(saved, rebuilt));
```

生成单个算例会保存并恢复调用前的 RNG 状态；加载数据不使用随机数。生成顺序或其他算法消耗多少随机数，都不会改变固定输入。生成器保持原场景的随机调用顺序，包括返回常量的 `randi(1, ...)`。

固定的是**输入场景**。随机搜索算法本身的随机性和按运行时间终止的行为，仍可能导致不同求解结果。MAT 文件头含写入时间，重复生成时应比较变量内容，而不是用文件字节或哈希判断数值复现。

## 数据字段

| 字段 | 含义 |
| --- | --- |
| `Target_num`、`UAV_num`、`Task_num` | 目标数、无人机数、任务数 |
| `Location` | `(Target_num + UAV_num) × 2` 坐标；目标在前，无人机初始位置在后；整数范围 1–100 |
| `Speed_UAV` | `UAV_num × 1` 飞行速度，整数范围 1–10 |
| `Task_require_UAV` | `1 × Task_num` 需求，保持原实验设置，全部为 1 |
| `H` | `Task_num × UAV_num` 执行耗时，整数范围 10–25 |
| `N` | `Task_num × UAV_num` 能力矩阵，保持原实验设置，每行恰有一个 1 |
| `Task_lo`、`Task_type` | 每个任务所属目标，以及阶段 1 或 2 |
| `Pre` | `Task_num × Task_num` 前驱矩阵；`Pre(2g, 2g-1) = 1` |
| `theta` | 初始位置索引 `Target_num + (1:UAV_num)` |
| `EM0` | 六元素初始调度状态：任务计数、开始时间、完成时间、位置、可用时间、任务序列 |
| `T_max` | 原实验时间预算 `UAV_num * Target_num / 10` |
| `seed`、`base_seed`、`rng_algorithm` | 种子及随机数算法 |
| `scale_name`、`scale_index`、`instance_index`、`run_index` | 算例标识 |
| `schema_version`、`folder`、`file_name` | 数据格式版本及文件标识 |

保留了原实验中“每任务需要一架无人机且只有一架可执行无人机”的生成规则，未改变问题分布。

## 验证

项目根目录下运行：

```matlab
addpath(fullfile(pwd, 'tests'));
report = validate_uav_datasets([], false);
```

验证范围包括文件数量、27 种配置、每配置 3 个算例、种子唯一性、数据维度与取值、前驱约束、初始状态、逐算例重生成一致性及 RNG 状态保持。

在包含原项目 10 份实验 `main.m` 的本地工作区，还可调用 `validate_uav_datasets()`，同时检查这些入口已改为 3 次运行并加载固定数据。
