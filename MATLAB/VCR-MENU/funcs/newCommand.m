function newCommand(name)

global cmd_list emptyWord

newWord = emptyWord;
newWord.name = name;
cmd_list = {cmd_list{:}, newWord};
saveCMD();