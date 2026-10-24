function spec = uav_instance_spec(scale_name, target_num, uav_num, run_index, base_seed)
%UAV_INSTANCE_SPEC Resolve a benchmark identifier and its independent seed.
if nargin < 5
    base_seed = 20261020;
end
validateattributes(target_num, {'numeric'}, {'scalar','real','finite','integer','positive'});
validateattributes(uav_num, {'numeric'}, {'scalar','real','finite','integer','positive'});
validateattributes(run_index, {'numeric'}, {'scalar','real','finite','integer','>=',1,'<=',3});
validateattributes(base_seed, {'numeric'}, ...
    {'scalar','real','finite','integer','>=',0,'<=',2^32 - 1 - 30903});

configs = uav_dataset_configs();
scale_index = find(strcmpi(string(scale_name), {configs.name}) | ...
    strcmp(string(scale_name), {configs.folder}), 1);
if isempty(scale_index)
    error('UAV:UnknownScale', 'Unknown scale: %s.', string(scale_name));
end
config = configs(scale_index);
instance_index = find(config.instances(:,1) == target_num & ...
    config.instances(:,2) == uav_num, 1);
if isempty(instance_index)
    error('UAV:UnknownConfiguration', ...
        'No %s benchmark with %d targets and %d UAVs.', config.name, target_num, uav_num);
end

spec.schema_version = '1.0';
spec.scale_name = config.name;
spec.scale_index = scale_index;
spec.instance_index = instance_index;
spec.run_index = double(run_index);
spec.Target_num = double(target_num);
spec.UAV_num = double(uav_num);
spec.base_seed = double(base_seed);
spec.seed = double(base_seed) + scale_index * 10000 + instance_index * 100 + double(run_index);
spec.rng_algorithm = 'twister';
spec.file_name = sprintf('%s_T%03d_U%03d_R%02d.mat', ...
    config.prefix, target_num, uav_num, run_index);
spec.folder = config.folder;
end
