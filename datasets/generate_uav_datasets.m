function manifest = generate_uav_datasets(output_root, base_seed)
%GENERATE_UAV_DATASETS Save 3 scales x 9 configurations x 3 runs as MAT files.
% Regeneration reproduces numeric contents; MAT headers may have timestamps.
if nargin < 1 || isempty(output_root)
    output_root = fileparts(mfilename('fullpath'));
end
if nargin < 2
    base_seed = 20261020;
end
configs = uav_dataset_configs();
entries = struct('file', {}, 'scale_name', {}, 'instance_index', {}, ...
    'run_index', {}, 'target_num', {}, 'uav_num', {}, 'task_num', {}, 'seed', {});
for scale_index = 1:numel(configs)
    config = configs(scale_index);
    scale_dir = fullfile(output_root, config.folder);
    if ~isfolder(scale_dir)
        mkdir(scale_dir);
    end
    for instance_index = 1:size(config.instances, 1)
        target_num = config.instances(instance_index, 1);
        uav_num = config.instances(instance_index, 2);
        for run_index = 1:3
            instance = create_uav_instance(config.name, target_num, uav_num, run_index, base_seed);
            file_path = fullfile(scale_dir, instance.file_name);
            save(file_path, '-struct', 'instance', '-v7');
            entries(end+1) = struct( ... %#ok<AGROW>
                'file', [config.folder '/' instance.file_name], ...
                'scale_name', config.name, ...
                'instance_index', instance_index, ...
                'run_index', run_index, ...
                'target_num', target_num, ...
                'uav_num', uav_num, ...
                'task_num', instance.Task_num, ...
                'seed', instance.seed);
        end
    end
    fprintf('%s: %d MAT instances written.\n', config.name, size(config.instances,1) * 3);
end
manifest = struct('schema_version', '1.0', 'base_seed', base_seed, ...
    'rng_algorithm', 'twister', ...
    'seed_formula', 'base_seed + scale_index * 10000 + instance_index * 100 + run_index', ...
    'scale_count', 3, 'configurations_per_scale', 9, 'runs_per_configuration', 3, ...
    'total_instances', numel(entries), 'instances', entries);
manifest_path = fullfile(output_root, 'manifest.json');
[fid, message] = fopen(manifest_path, 'w', 'n', 'UTF-8');
if fid == -1
    error('UAV:ManifestWriteFailed', 'Cannot write %s: %s', manifest_path, message);
end
close_manifest = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s\n', jsonencode(manifest, 'PrettyPrint', true));
fprintf('Total: %d instances; base seed: %d.\n', numel(entries), base_seed);
end
