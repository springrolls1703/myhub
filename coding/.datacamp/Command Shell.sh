#Correct! Both take the user's commands (whether typed or clicked) and send them to the operating system.
$pwd tells you where you are
$ls /home/repl shows you what's in your starting directory
If you are in the directory /home/repl, the relative path seasonal specifies the same directory as the absolute path $/home/repl/seasonal.
If you are in the directory /home/repl/seasonal, the relative path winter.csv specifies the same file as the absolute path /home/repl/seasonal/winter.csv

$cd 
(which stands for "change directory").

More often, though, you will take advantage of the fact that the special path .. (two dots with no spaces) means "the directory above the one I'm currently in"
$mv move files/ rename file
$rm remove files
$rmdir remove directories
$mkdir {directory_name} make new directory
$ ~ stand for current directory
$cat {file/folder} - show file content
If you give less the names of several files, you can type :n (colon and a lower-case 'n') to move to the next file, :p to go back to the previous one, or :q to quit.
$less
$more
$head -n 5 {file}
$ls -R recursive - to see anything underneath a directory
$man head to know what the command head do 
$cut -d {delimeter - for example ","} -f 2-5,8 take column 2 to 5 and 8
$history see history of command
$grep/Select-String select lines based on what it contains
$head -n 5 seasonal/summer.csv > top.csv redirect output to a new file
The command wc (short for "word count") prints the number of characters, words, and lines in a file. You can make it print only one of these using -c, -w, or -l respectively.
$wc -l
* to select multiple
$ wild card [...] match any of the characters inside the square bracket/ ? match a single character/ {...}

Ctrl + C - to end executing a command

$echo $variable show the variable value
shell_variable: a=b
The structure is for ...variable... in ...list... ; do ...body... ; done
$for filetype in gif jpg png; do echo $filetype; done
$nano 
wc -l $@ | grep -v total | sort -n | head -n 1

_______

$conda -v -know the version of conda
$conda install
$conda list --help
$conda list packages: packages that have installed. ex 
$conda update packages: update packages to the latest version
$conda remove packages: remove packages
$conda search packages: see what version is available
$conda search packages --info
$conda env list: display a list of environments on current system
$conda list 'numpy|pandas'
$conda list --name {environment_name}
$conda activate {environment_name} access another environment
$conda deactivate bring back to base environemt
$conda env remove {environment_name} remove environment
$conda env export -n {environment name to export} --file {file_name}.yml
$conda env create --file {environment_file}.yml 
$cat file - check the file
$python file - run python file
