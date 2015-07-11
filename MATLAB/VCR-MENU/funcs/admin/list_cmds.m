function list = list_cmds()
global cmd_list
list = sprintf('');
len = length(cmd_list);
for i = 1:len
    list = sprintf('%s%s#', list, cmd_list{i}.name );
end
list = regexp(list, '#', 'split');