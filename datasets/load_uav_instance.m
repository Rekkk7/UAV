function instance = load_uav_instance(scale_name, target_num, uav_num, run_index)
%LOAD_UAV_INSTANCE Load a saved benchmark, independently of pwd and RNG state.
spec = uav_instance_spec(scale_name, target_num, uav_num, run_index);
dataset_root = fileparts(mfilename('fullpath'));
file_path = fullfile(dataset_root, spec.folder, spec.file_name);
if ~isfile(file_path)
    error('UAV:MissingInstance', ...
        'Dataset not found: %s. Run generate_uav_datasets first.', file_path);
end
instance = load(file_path);
required_fields = {'schema_version','scale_name','scale_index','instance_index', ...
    'run_index','Target_num','UAV_num','base_seed','seed','rng_algorithm', ...
    'Task_num','Location','Speed_UAV','Task_require_UAV','H','N', ...
    'Task_lo','Task_type','Pre','theta','EM0','T_max'};
if ~all(isfield(instance, required_fields))
    error('UAV:InvalidInstance', 'Dataset is missing required fields: %s.', file_path);
end
if ~strcmp(instance.schema_version, spec.schema_version) || ...
        ~strcmp(instance.scale_name, spec.scale_name) || ...
        instance.scale_index ~= spec.scale_index || ...
        instance.instance_index ~= spec.instance_index || ...
        instance.run_index ~= spec.run_index || ...
        instance.Target_num ~= spec.Target_num || instance.UAV_num ~= spec.UAV_num
    error('UAV:InstanceMismatch', 'Dataset identifier does not match its file: %s.', file_path);
end
recorded_spec = uav_instance_spec(scale_name, target_num, uav_num, run_index, instance.base_seed);
if instance.seed ~= recorded_spec.seed || ~strcmp(instance.rng_algorithm, 'twister')
    error('UAV:SeedMismatch', 'Dataset RNG metadata is inconsistent: %s.', file_path);
end
end
