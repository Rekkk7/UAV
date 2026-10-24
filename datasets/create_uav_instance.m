function instance = create_uav_instance(scale_name, target_num, uav_num, run_index, base_seed)
%CREATE_UAV_INSTANCE Reproduce one instance without changing the caller's RNG.
% The random-call order and distributions match the original main.m scripts.
if nargin < 5
    base_seed = 20261020;
end
instance = uav_instance_spec(scale_name, target_num, uav_num, run_index, base_seed);
previous_rng = rng;
restore_rng = onCleanup(@() rng(previous_rng)); %#ok<NASGU>
rng(instance.seed, instance.rng_algorithm);

Task_num = 2 * target_num;
Location = randi(100, uav_num + target_num, 2);
Speed_UAV = randi(10, uav_num, 1);
Task_require_UAV = randi(1, 1, Task_num);
H = randi([10, 25], Task_num, uav_num);
N = zeros(Task_num, uav_num);
r = randi(1, 1, Task_num);
for i = 1:Task_num
    vec = [ones(1, r(i)), zeros(1, uav_num - r(i))];
    N(i,:) = vec(randperm(length(vec)));
end

Task_lo = repelem(1:target_num, 2);
Task_type = repmat([1, 2], 1, target_num);
Pre = zeros(Task_num);
for i = 2:2:Task_num
    Pre(i, i-1) = 1;
end
theta = target_num + (1:uav_num);
EM0 = {zeros(1,Task_num), zeros(uav_num,Task_num), ...
    zeros(uav_num,Task_num), theta, zeros(1,uav_num), cell(1,uav_num)};

instance.Task_num = Task_num;
instance.Location = Location;
instance.Speed_UAV = Speed_UAV;
instance.Task_require_UAV = Task_require_UAV;
instance.H = H;
instance.N = N;
instance.Task_lo = Task_lo;
instance.Task_type = Task_type;
instance.Pre = Pre;
instance.theta = theta;
instance.EM0 = EM0;
instance.T_max = uav_num * target_num / 10;
end
