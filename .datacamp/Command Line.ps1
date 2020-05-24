----Command Prompt command
$copy [filename] [folder to copy to] - copy file to one folder
$xcopy [folder name] [folder to copy to]
$xcopy /? - know what the command do 
$move [folder name] [folder to copy to]
$dir E: -print out the content of E without changing directory
$cls - clear the screen
$code . open code studio

----git command
$git clone https://github.com/springrolls1703/myhub {where to clone respitory}
$git remote -v: list the information
$git branch -a: list all the branch in respitory
$git add [file] :adding file to commit to branch
$git status :tell which branch on and if there are file ready to commit
$git commit -m '{message}'
$git log :know what commit command has been done


---starting with git
$git --version
$git config --global user.name "springrolls1703"
$git config --global user.email "ryan.nguyen1008@gmail.com"
$git config --list: list out the user detail
$git help config
$git diff -r HEAD: The -r flag means "compare to a particular revision", and HEAD is a shortcut meaning "the most recent commit". 
$git diff -r HEAD path/to/file
$git diff ID1..ID2: show the differences between two IDs
$git show: To view the details of a specific commit
--git show -r HEAD/HEAD~1/HEAD~2
$git annotate file: 
$git checkout -- filename: undo an action in a file
----


--tracking local project
$git init: initializing tracking local project
$git -rf .git: stop tracking
$touch .gitignore: put the name of the file in this [.gitignore] file to ignore these file while tracking
$git add -A: adding all file to commit
$git add [file]: adding a file to commit 
$git reset [file]: move the file to untracked file
$git status: checking the status of tracking file and untracked file
$git checkout
$git push https://github.com/springrolls1703/myhub master
$git pull https://github.com/springrolls1703/myhub master
$git reset pull

-----


--tracking team project
$git branch [name of the branch] create a branch
$git branch: list all the branch
$git pull origin master --allow-unrelated-histories: w
$git pull [project name] [branch name]: git pull myhub master
$git diff: see the change
$git show: To view the details of a specific commit
--git show -r HEAD/HEAD~1/HEAD~2
$git diff branch_1..branch_2: show the differences between two branches
$git checkout -b branchname: create a branch
$git init [projectname]: avoid create a respitory within a respitory this fuck things up
$git remote -v
ssaasda