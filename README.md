# UAV：81 个固定种子实验算例

用于异构多无人机任务分配与调度实验的 MATLAB 输入数据集。共 **3 个规模 × 9 种配置 × 3 个算例 = 81 个 MAT 文件**。

| 规模 | 目标数 | 无人机数 | 文件数 |
| --- | --- | --- | --- |
| [小规模](datasets/小规模) | 4、8、10 | 2、4、6 | 27 |
| [中规模](datasets/中规模) | 20、40、50 | 10、15、20 | 27 |
| [大规模](datasets/大规模) | 60、80、100 | 30、40、50 | 27 |

每个规模取表中目标数和无人机数的全部组合。每个目标有两个顺序任务，每个配置提供 `R01`、`R02`、`R03` 三个独立算例。

## 在 MATLAB 中使用

在仓库根目录执行：

```matlab
addpath(fullfile(pwd, 'datasets'));
data = load_uav_instance('Small-Scale', 4, 2, 1);
```

`data` 包含位置、速度、执行时间、能力矩阵、前驱约束、初始调度状态和种子等完整输入。原有实验循环可设为：

```matlab
num_runs_per_instance = 3;
for run = 1:num_runs_per_instance
    data = load_uav_instance(scale_name, Target_num, UAV_num, run);
    % 从 data 读取算法需要的输入字段。
end
```

## 固定种子与验证

基础种子为 `20261020`，使用 MATLAB `twister`，每个算例的种子为：

```text
seed = 20261020 + scale_index * 10000 + instance_index * 100 + run_index
```

完整种子清单见 [manifest.json](datasets/manifest.json)，数据字段、命名规则及重生成方法见 [数据集说明](datasets/README.md)。

```matlab
addpath(fullfile(pwd, 'tests'));
report = validate_uav_datasets([], false);
```

数据已使用 MATLAB R2024b Update 2 验证：81 个文件、每规模 27 个、每配置 3 个、81 个不同种子、字段结构与约束正确、逐个重新生成的内容完全一致、生成和加载均保持调用方随机数状态。

本仓库包含输入数据、生成/加载工具及验证脚本。保留原实验的数据分布：每个任务需要一架无人机，且能力矩阵每行仅有一架可执行无人机。固定输入不等于固定随机搜索算法的求解结果。
