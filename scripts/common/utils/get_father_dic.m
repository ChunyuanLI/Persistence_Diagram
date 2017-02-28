function father_DIR = get_father_dic(DIR,n)

% go to father directory
% n: the level to go back to

index_dir=findstr(DIR,'\');
father_DIR=DIR(1:index_dir(end-n+1)-1);

end