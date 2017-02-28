function run_experiment_vocab_size(BOF_DIR, DIRNAME, DESCNAME, tau)

bofdir   = fullfile(fullfile(BOF_DIR, DESCNAME),   DIRNAME);

% BoFs
bofs = dir(fullfile(bofdir, sprintf('bof-visual.*.mat')));
bofs = {bofs.name};
FIELDS  = cellfun(@(x)(split(chop_extension(x),'-','cell')), bofs, 'UniformOutput', false);
V   = cellfun(@(x)(str2num(x{2}(8:end))), FIELDS, 'UniformOutput', true);

BOF_EER = [];
for k=1:length(V),
    [ALL] = compute_bof_rates(fullfile(bofdir, bofs{k}));
    BOF_EER(k,:) = [V(k) ALL.eer];
end


% Pair BoFs
bofs = dir(fullfile(bofdir, sprintf('dbof-visual.*-%.2f.mat', tau)));
bofs = {bofs.name};
FIELDS  = cellfun(@(x)(split(chop_extension(x),'-','cell')), bofs, 'UniformOutput', false);
V   = cellfun(@(x)(str2num(x{2}(8:end))), FIELDS, 'UniformOutput', true);

DBOF_EER = [];
for k=1:length(V),
    [ALL] = compute_bof_rates(fullfile(bofdir, bofs{k}));
    DBOF_EER(k,:) = [V(k) ALL.eer];
end

% SS-BoFs
bofs = dir(fullfile(bofdir, sprintf('ssbof-visual.*-spatial.*-%.2f.mat', tau)));
bofs = {bofs.name};
FIELDS  = cellfun(@(x)(split(chop_extension(x),'-','cell')), bofs, 'UniformOutput', false);
V   = cellfun(@(x)(str2num(x{2}(8:end))), FIELDS, 'UniformOutput', true);
S   = cellfun(@(x)(str2num(x{3}(9:end))), FIELDS, 'UniformOutput', true);

SSBOF_EER = [];
for k=1:length(V),
    [ALL] = compute_bof_rates(fullfile(bofdir, bofs{k}));
    SSBOF_EER(k,:) = [V(k) S(k) ALL.eer];
end



% Sort by vocab sizes
BOF_EER   = sortrows(BOF_EER);
DBOF_EER  = sortrows(DBOF_EER);
SSBOF_EER = sortrows(SSBOF_EER);

% Plot results
figure; set(gcf, 'Name', 'EER vs vocabulary size');
h = plot(BOF_EER(:,1), BOF_EER(:,2)*100, 'b');
set(h, 'LineWidth', 1.25);
hold on;
h = plot(DBOF_EER(:,1), DBOF_EER(:,2)*100, 'g');
set(h, 'LineWidth', 1.25);
ss = unique(SSBOF_EER(:,2));
for k=1:length(ss),
    idx = find(SSBOF_EER(:,2) == ss(k)); 
    h = plot(SSBOF_EER(idx,1), SSBOF_EER(idx,3)*100, 'r');
    set(h, 'LineWidth', 1.25);
    x = 0.5*(BOF_EER(1,1)+BOF_EER(2,1));
    y = 0.5*(SSBOF_EER(idx(1),3)+SSBOF_EER(idx(2),3));    
    h = text(x,y*100, sprintf(' %d ', ss(k)));
    set(h, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'BackgroundColor', [1 1 1], 'Color', [1 0 0]);
end
hold off;
set(gca, 'XLim', [min(BOF_EER(:,1)) max(BOF_EER(:,1))]);
xlabel('Visual vocabulary size');
ylabel('EER [%]');
legend('BoF', 'P-BoF', 'SS-BoF');


