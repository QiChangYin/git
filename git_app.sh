#!/usr/bin/env bash
####################################################################################################
#
# Version: v3.6
# Date: 2017-06-03
# File: git_app.sh
# Author: QiChang.Yin
# Git version: git version 2.7.4
# Kernel version: 4.4.0-21-generic
# Operation system: Ubuntu version 16.04
# Instruction: The script is convenient for using Git distributed version and control system.
#
###################################################################################################


#添加Controller的IP地址和端口号
CONTROLLER_IP_ADDRESS="192.168.0.100"
CONTROLLER_PORT_NUMBER="22"


#设置当前用户分支最大数目和最小数目
CHECKOUT_BRANCH_INDEX_MAX=30
CHECKOUT_BRANCH_INDEX_MIN=0


#主分支名称
MASTER_BRANCH_NAME="develop"

# 与分支相关的文件
DELETE_FILE="delete_file.txt"
RESERVE_FILE="reserve_file.txt"
BRANCH_FILE="branch_file.txt"
TEMP_FILE="temp_file.txt"
WANT_PUSH_FILE="want_push_file.txt"
SAVE_MODIFY_FILE="save_modify_file.txt"
HAS_GIT_ADD_FILE="has_git_add_file.txt"

#这个是提示符号的个数和提示内容的左右空格个数
COUNT_DEFAULT=100
MSG_LEFT_AND_RIGHT_SPACE=3

# 消息中是否包含issue
ISSUE_FLAG=1;

#添加用户，包括用户的名称和MAC地址
PERSON_ARRAY=(
    "Yqc/00:0c:29:e8:16:95"
)


#不同提示信息的提示符号的类型
I_INFO="♝"
S_INFO="❉"
W_INFO="⚘"
F_INFO="☥"
N_INFO="⚓"
L_INFO="♛"
P_INFO="✯"


#这个是提示信息颜色
SETCOLOR_SUCCESS='\E[1;32m'    # SETCOLOR_SUCCESS 设置后面的字体都为绿色(成功提示)
SETCOLOR_FAILURE='\E[1;31m'    # SETCOLOR_FAILURE 设置后面将要输出的字体都为红色(错误提示)
SETCOLOR_WARNING='\E[1;33m'    # SETCOLOR_WARNING 设置后面将要输出的字体都为黄色(警告提示)
SETCOLOR_NORMAL='\E[1;39m'     # SETCOLOR_NORMAL 设置后面输出的字体都为白色（默认提示）
SETCOLOR_INFO='\E[1;34m'       # SETCOLOR_INFO 设置后面输出的字体都为蓝色（信息提示）
SETCOLOR_LOGIN='\E[1;35m'      # SETCOLOR_LOGIN 设置后面输出的字体都为紫色（登录成功提示）
SETCOLOR_PERMISSION='\E[1;36m' # SETCOLOR_PERMISSION 设置后面输出的字体都为天兰色（登录失败提示）


# echo 输出函数的重写
function ECHO
{
    var=1
    msg=$3
    color=""
    mark=""
    type_right=""
    type_left=""
    if [[ $2 == "" ]];
    then
        color="i"
    else
        if [[ $1 == "~" ]];
        then
            mark="*"
            color=$2
        else
            mark=$1
            color=$2
        fi
    fi
    if [[ $3 != "" ]];
    then
        msg_length=$(echo $3 | wc -L)
        if [[ $msg_length%2 -ne 0 ]];
        then
            let "msg_length+=1"
        fi
    else
        msg_length=0
    fi

    if [[ $msg_length -eq 0 ]];
    then
        msg=""
    elif [[ $msg_length -gt 0 ]];
    then
        let "msg_length+=$[MSG_LEFT_AND_RIGHT_SPACE*2]"
        while(( $var<=$MSG_LEFT_AND_RIGHT_SPACE ))
        do
            msg=${msg}" "
            let "var++"
        done
        var=1
        while(( $var<=$MSG_LEFT_AND_RIGHT_SPACE ))
        do
            msg=" "${msg}
            let "var++"
        done
    fi
    if [[ $4 != "" ]];
    then
        count=$4
    else
        count=$COUNT_DEFAULT
    fi
    var=1
    while(( $var<=$[$[count-msg_length]/2] ))
    do
        type_left="$mark"${type_left}
        let "var++"
    done
    var=1
    while(( $var<=$[$[count-msg_length]/2] ))
    do
        type_right=${type_right}"$mark"
        let "var++"
    done
    case $color in
    s)
        echo  -e "${SETCOLOR_SUCCESS}$type_left$msg$type_right${RES}"
        echo  -en  "${SETCOLOR_NORMAL}""${RES}"
    ;;
    w)
        echo -e  "${SETCOLOR_WARNING}$type_left$msg$type_right${RES}"
        echo  -en  "${SETCOLOR_NORMAL}""${RES}"
    ;;
    f)
        echo -e  "${SETCOLOR_FAILURE}$type_left$msg$type_right${RES}"
        echo  -en  "${SETCOLOR_NORMAL}""${RES}"
    ;;
    i)
        echo -e  "${SETCOLOR_INFO}$type_left$msg$type_right${RES}"
        echo  -en  "${SETCOLOR_NORMAL}""${RES}"
    ;;
    l)
        echo -e  "${SETCOLOR_LOGIN}$type_left$msg$type_right${RES}"
        echo  -en  "${SETCOLOR_NORMAL}""${RES}"
    ;;
    p)
        echo -e  "${SETCOLOR_PERMISSION}$type_left$msg$type_right${RES}"
        echo  -en  "${SETCOLOR_NORMAL}""${RES}"
    ;;
    n)
        echo -e  "${SETCOLOR_NORMAL}$type${RES}"
    ;;
    *)
       exit 1
    esac
}

# 函数的功能：帮助函数，查看脚本的命令
function git_app_help
{
    judge_login_user_legality
    echo "============================================================================================================="
    echo "= ========================================================================================================= ="
    echo "= =     1:  No password : git config --global credential.helper store                                     = ="
    echo "= =         ssh-keygen -t rsa                                                                             = ="
    echo "= =         cat ~/.ssh/id_rsa.pub | ssh vectioneer@192.168.0.100 'cat >> .ssh/authorized_keys'            = ="
    echo "= ========================================================================================================= ="
    echo "= =     2:  创建新分支:                                                                                   = ="
    echo "= =         命令：./git_app.sh cb  AAA_BBBB   or  ./git_app.sh cb  BBBB                                   = ="
    echo "= =         备注： AAA:问题号   BBBB:问题描述                                                             = ="
    echo "= =         创建的分支由你自己名字的首字母,当前日期,问题描述三部分组成.                                   = ="
    echo "= =         此处首先将当前分之保存到暂存区,然后切换到develop分支拉下最新代码,切换到创建的分支.            = ="
    echo "= ========================================================================================================= ="
    echo "= =     3:  提交分支方法一:./git_app.sh acp x                                                             = ="
    echo "= =         ap:表示连续执行git add  git commit  git push命令                                              = ="
    echo "= =         添加信息组成:个人名字的首字母以及对应分支名称的部分字符串.                                    = ="
    echo "= =         命令1:./git_app.sh acp 1 2 3 ... n                                                            = ="
    echo "= =         备注:1 2 3 ... n 代表没有git add文件的排列顺序编号,改动的文件可能会很多,只需选择自己          = ="
    echo "= =              想提交的文件编号即可,已经git add的文件，默认会git commit,不参与编号.                     = ="
    echo "= =         命令2:./git_app.sh acp all                                                                    = ="
    echo "= =         备注:将会提交所有的文件,包括已经git add的文件和没有git add的文件.                             = ="
    echo "= ========================================================================================================= ="
    echo "= =     4:  提交分支方法二: ./git_app.sh mp all                                                           = ="
    echo "= =         mp:表示连续执行git commit  git push命令,那么需要你自己使用git add命令添加自己想提交的文件,    = ="
    echo "= =              这条命令只识别已经git add的文件.                                                         = ="
    echo "= =         添加信息组成:个人名字的首字母以及对应分支名称的部分字符串.                                    = ="
    echo "= =         命令：./git_app.sh mp all                                                                     = ="
    echo "= =         备注：先执行git add 选择保存到暂存区的文件，然后提交.                                         = ="
    echo "= ========================================================================================================= ="
    echo "= =     5:  提交分支方法三: ./git_app.sh fp all                                                           = ="
    echo "= =         ap:表示连续执行git add  git commit  git push命令,主要作用是重写提交消息.                      = ="
    echo "= =         命令1:./git_app.sh fp "BBBB" 1 2 3 ... n                                                        = ="
    echo "= =         备注:BBBB表示添加信息,1 2 3 ... n 代表没有git add文件的排列顺序编号,改动的文件可能会很多,     = ="
    echo "= =              只需选择自己想提交的文件编号即可,已经git add的文件，默认会git commit,不参与编号.         = ="
    echo "= =         命令2:./git_app.sh fp "BBBB" all                                                                = ="
    echo "= =         备注:BBBB表示添加信息,将会提交所有的文件,包括已经git add的文件和没有git add的文件.            = ="
    echo "= ========================================================================================================= ="
    echo "= =     6:  提交分支方法三: ./git_app.sh fp all                                                           = ="
    echo "= =         ap:表示连续执行git add  git commit  git push命令,主要作用是重写提交消息.                      = ="
    echo "= =         命令1:./git_app.sh fp "BBBB" 1 2 3 ... n                                                        = ="
    echo "= =         备注:BBBB表示添加信息,1 2 3 ... n 代表没有git add文件的排列顺序编号,改动的文件可能会很多,     = ="
    echo "= =              只需选择自己想提交的文件编号即可,已经git add的文件，默认会git commit,不参与编号.         = ="
    echo "= =         命令2:./git_app.sh fp "BBBB" all                                                                = ="
    echo "= =         备注:BBBB表示添加信息,将会提交所有的文件,包括已经git add的文件和没有git add的文件.            = ="
    echo "= ========================================================================================================= ="
    echo "= =     7:  根据日期删除本地分支: ./git_app.sh dld x                                                      = ="
    echo "= =         dl:表示执行git branch -D <branchName>命令，删除本地分之                                       = ="
    echo "= =      　　./git_app.sh dld 　AAAA  表示删除对应日期AAAA的所有分支.                                     = ="
    echo "= =     　　 ./git_app.sh dld   AAAA  表示删除日期AAAA~日期BBBB之间的所有分支.                            = ="
    echo "= ========================================================================================================= ="
    echo "= =     8:  根据问题号删除本地分支: ./git_app.sh dld x                                                    = ="
    echo "= =         dl:表示执行git branch -D <branchName>命令，删除本地分之                                       = ="
    echo "= =      　　./git_app.sh dli　AAAA  *AAAA:表示问题号, 表示删除对应问题号的所有分支.                      = ="
    echo "= =     　　 ./git_app.sh dli  AAAA  BBBB  *AAAA/BBBB:表示问题号,表示删除问题号AAAA~BBBB之间的所有分支.   = ="
    echo "= ========================================================================================================= ="
    echo "= =     9:  根据日期删除远程分支: ./git_app.sh dod x                                                      = ="
    echo "= =         dl:表示执行git push origin :<branchName>,                                                     = ="
    echo "= =      　　./git_app.sh dod 　AAAA  *AAAA:表示日期, 表示删除对应日期的所有分支.                         = ="
    echo "= =     　　 ./git_app.sh dod   AAAA  BBBB  *AAAA/BBBB:表示日期,表示删除日期AAAA~日期BBBB之间的所有分支.  = ="
    echo "= ========================================================================================================= ="
    echo "= =     10:  根据问题号删除远程分支: ./git_app.sh doi x                                                   = ="
    echo "= =         dl:表示执行git branch -D <branchName>命令，删除本地分之                                       = ="
    echo "= =      　　./git_app.sh doi　AAAA  *AAAA:表示问题号, 表示删除对应问题号的所有分支.                      = ="
    echo "= =     　　 ./git_app.sh doi  AAAA  BBBB  *AAAA/BBBB:表示问题号,表示删除问题号AAAA~BBBB之间的所有分支.   = ="
    echo "= ========================================================================================================= ="
    echo "= =     11:  删除远程分支: ./git_app.sh do x                                                              = ="
    echo "= =         dl:表示执行git push origin :<branchName>,                                                     = ="
    echo "= =      　　./git_app.sh dl 　AAA   AAA:问题号 表示删除对应问题号的所有分支.                             = ="
    echo "= =    　　　./git_app.sh dl   BBBB  BBBB:日期  表示删除对应日期的所有分支.                               = ="
    echo "= =     　　 ./git_app.sh dl   BBBB  DDDD 日期  表示删除日期BBBB~日期DDDD之间的所有分支.                  = ="
    echo "= ========================================================================================================= ="
    echo "= =     12:  切换本地分支：./git_app.sh ch AAA  AAA:问题号                                                = ="
    echo "= =          切换本地分支：./git_app.sh ch AAA  AAA:git branch的序号                                      = ="
    echo "= ========================================================================================================= ="
    echo "= =     13:  合并develop到当前分支：./git_app.sh mg dp                                                    = ="
    echo "= =          此处首先会切换到develop分之拉下最新代码,然后切换到当前分之合并develop分之,最后查看冲突文件.  = ="
    echo "= ========================================================================================================= ="
    echo "= =     14:  查看脚本信息: ./git_app.sh v  or -v  or version                                              = ="
    echo "= =     15:  查看帮助信息：./git_app.sh    or -h  or h  or help                                           = ="
    echo "= =     16:  查看本地分支: ./git_app.sh b  or -b  or branch                                               = ="
    echo "= =     17:  查看代码修改：./git_app.sh s  or -s  or status                                               = ="
    echo "= ========================================================================================================= ="
    echo "= =     18:  运行本机脚本 kill_app.sh : ./git_app.sh k                                                    = ="
    echo "= =     19:  运行本机脚本 run_all_in_one.sh : ./git_app.sh r                                              = ="
    echo "= =     20:  运行本机脚本 kill_app.sh和run_all_in_one.sh : ./git_app.sh kr                                = ="
    echo "= =     21:  运行本机脚本 release.sh：./git_app.sh rl                                                     = ="
    echo "= =     22:  运行本机脚本 tp_hardware_service.sh：./git_app.sh th                                         = ="
    echo "= =     23:  运行本机脚本 vectioneer_controller_shutdown_service.sh：./git_app.sh cv                      = ="
    echo "= =     24:  将tp_server压缩包copy到controller：./git_app.sh cp                                           = ="
    echo "= ========================================================================================================= ="
    echo "= =     25:  登录controller：./git_app.sh ctl                                                             = ="
    echo "= =     26:  重启controller：./git_app.sh ctb                                                             = ="
    echo "= =     27:  运行controller脚本 kill_app.sh : ./git_app.sh   ctk                                          = ="
    echo "= =     28:  运行controller脚本 run_all_in_one.sh : ./git_app.sh  ctr                                     = ="
    echo "= ========================================================================================================= ="
    echo "= =     29:  打开新的终端：./git_app.sh nt                                                                = ="
    echo "= =     30:  打开bitbucket：./git_app.sh bt                                                               = ="
    echo "= =     31:  打开阿里邮箱：./git_app.sh em                                                                = ="
    echo "= =     32:  打开百度：./git_app.sh bd                                                                    = ="
    echo "= =     33:  打开Pycharm:  ./git_app.sh pc                                                                = ="
    echo "= =     34:  同步远程分支到本地分支:  ./git_app.sh grpo                                                　 = ="
    echo "= =     35:  取消当前分支的修改:  ./git_app.sh gcho                                                   　  = ="
    echo "============================================================================================================="
}


# 函数的功能：查看脚本的版本信息
function git_app_version
{
    echo "####################################################################################################"
    echo "#"
    echo "# Version: v3.6"
    echo "# Date: 2017/06/03"
    echo "# File: git_app.sh"
    echo "# Author: QiChang.Yin"
    echo "# Git version: git version 2.7.4"
    echo "# Kernel version: 4.4.0-21-generic"
    echo "# Operation system: Ubuntu version 16.04"
    echo "# Copyright: Copyright © 2016 Foresight-Robotics Ltd. All rights reserved."
    echo "# Instruction: The scrpit is convenient for using Git distributed version and control system."
    echo "#"
    echo "###################################################################################################"
}


# 函数的功能：将同步远程分支
function git_remote_prune_origin
{
    judge_login_user_legality
    ECHO $I_INFO i
    ECHO $I_INFO i "You will git remote prune origin"
    ECHO $I_INFO i
    git stash
    git checkout develop
    git remote prune origin
    git pull
}


# 函数的功能：清理本地修改代码
function git_clean_and_checkout
{
    judge_login_user_legality
    ECHO $I_INFO i
    ECHO $I_INFO i " You will git clean -df and git checkout -- ."
    ECHO $I_INFO i
    git clean -df
    git checkout -- .
    git stash
}


#　函数的功能：打开新的终端
function open_new_terminal
{
    judge_login_user_legality
    ECHO $I_INFO i
    ECHO $I_INFO i "You will open new terminal"
    ECHO $I_INFO i
    gnome-terminal
}


#　函数的功能：打开pycharm软件
function open_pycharm
{
    judge_login_user_legality
    ECHO $I_INFO i
    ECHO $I_INFO i "You will open PyCharm"
    ECHO $I_INFO i
    /usr/local/bin/charm &
    sleep 4
    clear
}


# 函数的功能：打开bitbucket链接
function open_bitbucket
{
    judge_login_user_legality
    ECHO $I_INFO i
    ECHO $I_INFO i "You will open bitbucket"
    ECHO $I_INFO i
    /opt/google/chrome/google-chrome  https://bitbucket.org/forsightrobotics/tp_robot_fst/wiki/Home &
    sleep 4
    clear
}


# 函数的功能：打开百度
function open_baidu
{
    judge_login_user_legality
    ECHO $I_INFO i
    ECHO $I_INFO i "You will open baidu"
    ECHO $I_INFO i
    /opt/google/chrome/google-chrome  https://www.baidu.com/ &
    sleep 4
    clear
}


# 函数的功能：打开阿里邮件
function open_ali_email
{
    judge_login_user_legality
    ECHO $I_INFO i
    ECHO $I_INFO i "You will open ali email"
    ECHO $I_INFO i
    /opt/google/chrome/google-chrome  http://mail.foresight-robotics.com/alimail/auth/login?custom_login_flag=1&reurl=%2Falimail%2F &
    sleep 4
    clear
}


#　函数的功能：根据MAC地址获取当前登陆用户
function judge_current_login_user
{
    ifconfig | while read line
    do
        if [[ $line =~ "HWaddr" || $line =~ "硬件地址" ]];
        then
            if [[ $line =~ "HWaddr" ]];
            then
               e=$(echo ${line:37:18})
            else
               e=$(echo ${line:31:18})
            fi
            for person in ${PERSON_ARRAY[@]}
            do
                HWAddr=$(echo ${person##*/})
                if [[ $e == $HWAddr ]];
                then
                    current_person=$(echo ${person%%/*})
                    echo $current_person
                fi
            done
            currentPerson=""
            echo $currentPerson
        fi
    done
}


#　函数的功能：判断当前的登录用户是否有权限
function judge_login_user_legality
{
    #current_person=$(judge_current_login_user)
    #if [[ $current_person == "" ]];
    #then
    #    ECHO $P_INFO "p"
    #    ECHO $P_INFO "p" "You do not have permission to use this script, Please contact the administrator!"
    #    ECHO $P_INFO "p"
    #    exit 1
    #else
    #    ECHO $L_INFO "l"
    #    ECHO $L_INFO "l" "Hello $current_person Welcome!!!"
    #    ECHO $L_INFO "l"
    #fi
}


#　函数的功能：创建新的分支
function create_new_branch
{
    judge_login_user_legality
    current_person=$(judge_current_login_user)
    a=$2
    count_first_char_length=$(echo ${#a})
    if [[ $a  ==  *[!0-9]* ]];
    then
        if [[  $a =~ "_"  ]];
        then
            b=$(echo ${a%%_*})
            if [[ $b == *[!0-9]* ]];
            then
                e=$2
            else
                e=$b
            fi
        else
            e=$2
        fi
    else
        e=$2
    fi
    if [ "$e" -gt 0 ] 2>/dev/null ;
    then
        DATA=`date "+%m%d"`
        branch_name="$current_person""_""$DATA"
        count=0
        for line in $*
        do
            count=$(($count+1))
            if [[ $2 == *[!0-9]* ]];
            then
                f=${2//_/" "};
                for c in $f
                do
                    if [[ $c == *[!0-9]* ]] ;
                    then
                        branch_name="$branch_name""_"$c
                    else
                        branch_name="$branch_name""_#"$c
                    fi
                done
                break;
            else
                if [[ count -gt 1 ]];then
                    if [[ $line == *[!0-9]* ]] ;
                    then
                        branch_name="$branch_name""_"$line
                    else
                        branch_name="$branch_name""_#"$line
                    fi
                fi
            fi
        done
    else
        ECHO $W_INFO "w" "警告信息, 创建本地分支的第一个参数不是任务号或者根本没有任务号! "
        ECHO $W_INFO "w"
        DATA=`date "+%m%d"`
        branch_name="$current_person""_""$DATA"
        count=0
        for line in $*
        do
            count=$(($count+1))
            if [[ count -gt 1 ]];then
                if [[ $line == *[!0-9]* ]];
                then
                    branch_name="$branch_name""_"$line
                else
                    branch_name="$branch_name""_#"$line
                fi
            fi
        done
    fi
    ECHO $I_INFO i "将要创建的分支名："$branch_name
    git branch | ( while read line
    do
        if [[ "$line" == "$branch_name" ]];
        then
            ECHO $F_INFO "f" "创建分支与本地分支重复,请重新创建分支"
            echo $line
            ECHO $F_INFO "f"
            exit 1
        fi
    done
    git stash
    git checkout develop
    git reset .
    git checkout -- .
    git clean -df
    git pull
    git checkout -b $branch_name
    ECHO $S_INFO "s" "本地分支创建成功！"
    git branch
    ECHO $S_INFO "s"
    )
}

function create_temp_file
{
    if [ ! -f $1 ];
    then
        touch $1
    else
        rm    $1
        touch $1
    fi
}

#　函数的功能：根据日期和任务号删除本地分支
function delete_local_branch
{
    judge_login_user_legality
    if [ $# -lt 2 ];
    then
        echo "1st argument is empty"
        exit 1
    fi
    git stash
    git checkout $MASTER_BRANCH_NAME
    create_temp_file $DELETE_FILE
    git branch | while read line
    do
        if [[ $line =~ $MASTER_BRANCH_NAME ]];
        then
            continue
        fi
        if [ "$1" == "dld" ];
        then
            a=$(echo ${line#*_})
            b=$(echo ${a%%_*})
            c=$(echo $b | awk '{print int($0)}')
        elif [ "$1" == "dli" ];
        then
            a=$(echo ${line#*#})
            b=$(echo ${a%%_*})
            c=$(echo $b | awk '{print int($0)}')
        fi
        if [ $# -eq 2 ];
        then
            if [ $2 -eq $c ];
            then
                git branch -D $line
                echo $line >> $DELETE_FILE
            fi
        elif [ $# -eq 3 ];
        then
            if [ $2 -le $c ] && [ $3 -ge $c ];
            then
                git branch -D $line
                echo $line >> $DELETE_FILE
            fi
        fi
    done
    ECHO $S_INFO "s" "删除的本地分支名称列表如下："
    cat $DELETE_FILE
    ECHO $I_INFO "i"
    rm  $DELETE_FILE
    ECHO $S_INFO "s" "保留的本地分支名称列表如下："
    git branch
    ECHO $S_INFO "s"
}


#　函数的功能：根据日期和任务号删除远程分支
function delete_origin_branch
{
    judge_login_user_legality
    judge_person=$(judge_current_login_user)
    if [ $# -lt 2 ];
    then
        echo "1st argument is empty"
        exit 1
    fi
    git stash
    git checkout $MASTER_BRANCH_NAME
    create_temp_file $DELETE_FILE
    git branch -r | grep "$judge_person" | while read line
    do
        if [[ $line =~ $MASTER_BRANCH_NAME ]];
        then
            continue
        fi
        if [ $1 == "dod" ];
        then
            a=$(echo ${line#*_})
            b=$(echo ${a%%_*})
            c=$(echo $b | awk '{print int($0)}')
        elif [ $1 == "doi" ];
        then
            a=$(echo ${line#*#})
            b=$(echo ${a%%_*})
            c=$(echo $b | awk '{print int($0)}')
        fi
        if [ $# -eq 2 ];
        then
            if [ $2 -eq $c ];
            then
                git branch -D -r $line
                echo $line >> $DELETE_FILE
            fi
        elif [ $# -eq 3 ];
        then
            if [ $2 -le $c ] && [ $3 -ge $c ];
            then
                git branch -D -r $line
                echo $line >> $DELETE_FILE
            fi
        fi
    done
    ECHO $S_INFO "s" "删除的远程分支名称列表如下："
    cat $DELETE_FILE
    ECHO $I_INFO "i"
    rm  $DELETE_FILE
    ECHO $S_INFO "s" "保留的远程分支名称列表如下："
    git branch -r | grep "$judge_person"
    ECHO $S_INFO "s"
}


#　函数的功能：执行git add/git commit/git push命令
function add_commit_push_current_modify
{
    if [[ $2 == "all" ]];
    then
       # git add .
       #commit_push_current_modify $1 $2
       exit 1
    fi
    judge_login_user_legality
    judge_person=$(judge_current_login_user)
    commitFlag=0
    addFileFlag=0

    create_temp_file $SAVE_MODIFY_FILE
    git status | while read line
    do
        if [[ $line =~ "git reset HEAD" ]];
        then
            addFileFlag=1
            continue
        elif [[ $addFileFlag == 1 ]];
        then
            if [[ $line =~ "git add"  ]];
            then
                addFileFlag=0
                continue
            else
                if [[ $line =~ "new file:" || $line =~ "modified:" || $line =~ "deleted:" || $line =~ "renamed:" ]];
                then
                    a=$(echo ${line#*:})
                    echo $a >> $HAS_GIT_ADD_FILE
                elif [[ $line =~ "新文件：" || $line =~ "修改：" || $line =~ "删除：" || $line =~ "重命名：" ]];
                then
                    a=$(echo ${line#*：})
                    echo $a >> $HAS_GIT_ADD_FILE
                else
                    continue
                fi
            fi
        elif [[ $addFileFlag == 0 ]];
        then
            if [[ $line =~ "new file:" || $line =~ "modified:" || $line =~ "deleted:" || $line =~ "renamed:" ]];
            then
                a=$(echo ${line#*:})
                echo $a >> $SAVE_MODIFY_FILE
            elif [[ $line =~ "新文件：" || $line =~ "修改：" || $line =~ "删除：" || $line =~ "重命名：" ]];
            then
                a=$(echo ${line#*：})
                echo $a >> $SAVE_MODIFY_FILE
            else
                continue
            fi
        fi
    done
    git clean -ndf  | while read line
    do
        if [[  $line =~ $SAVE_MODIFY_FILE  ||  $line =~ $HAS_GIT_ADD_FILE ]] ;
        then
            continue
        elif [[ $line =~ "Would remove" ]];
        then
            e=$(echo ${line:10:100})
            echo $e >> $SAVE_MODIFY_FILE
        elif [[ $line =~ "将删除" ]];
        then
            e=$(echo ${line:4:100})
            echo $e >> $SAVE_MODIFY_FILE
        else
            continue
        fi
    done
    
    create_temp_file $WANT_PUSH_FILE
    count=1
    cat $SAVE_MODIFY_FILE | while read line
    do
        for arg in "$@"
        do
            if [[ $arg == *[!0-9]* ]];
            then
                continue
            elif [ $arg -eq $count ];
            then
                if [[ $line =~ "git_app.sh" ]];
                then
                    continue
                else
                    git add $line
                    echo $line >> $WANT_PUSH_FILE
                fi
            fi
        done
        count=$(($count+1))
    done
    rm $SAVE_MODIFY_FILE
    
    if [ -s $HAS_GIT_ADD_FILE ];
    then
        ECHO $S_INFO "s" "已经通过git add添加的文件列表如下："
        cat $HAS_GIT_ADD_FILE
        ECHO $S_INFO "s"
    else
        echo ""
    fi
    rm $HAS_GIT_ADD_FILE

    ECHO $I_INFO "i" "想要git push的文件列表如下："
    cat  $WANT_PUSH_FILE
    ECHO $I_INFO "i"
    rm $WANT_PUSH_FILE

    git branch | grep "*" |  while read  line
    do
        a=$(echo ${line:1:100})
        commit_message=${a//_/" "};
        if [[ $commit_message =~ "#" &&  $ISSUE_FLAG -eq 1 ]] ;
        then
            commit_message=${commit_message//#/"issue:#"};
        fi
        ECHO $S_INFO "s" "git commit的备注信息如下："
        echo $commit_message
        ECHO $S_INFO "s"
        git commit  -m "$commit_message"
    done

    push_file="push.txt"
    if [ ! -f "push_file" ];
    then
        touch $push_file
    else
        rm  $push_file
        touch $push_file
    fi
    git push 2> $push_file
    cat $push_file
    cat $push_file | ( while read line
    do
        if [[ $line =~ "--set-upstream" ]];then
            cmd=$line
            $cmd
            ECHO $S_INFO s "已经git push成功,你使用的git push命令如下："
            echo $line
            ECHO $S_INFO s
            commitFlag=1
            rm  $push_file
            exit 1
        elif [[ $line =~ "push origin" ]];
        then
            if [[ $line =~ "HEAD:" ]];
            then
                continue
            else
                cmd=$line
                $cmd
                ECHO $S_INFO s "已经git push成功,你使用的git push命令如下："
                echo $line
                ECHO $S_INFO s
                commitFlag=1
                rm  $push_file
                exit 1
            fi
        elif [[ $line =~ "Everything up-to-date" ]];then
            current_branch_file="current_branch.txt"
            if [ ! -f "$current_branch_file" ];
            then
                touch $current_branch_file
            else
                rm  $current_branch_file
                touch $current_branch_file
            fi
            git branch | grep "*" > $current_branch_file
            cat $current_branch_file | while read  line
            do
                e=$(echo ${line:1:100})
            done
            rm $current_branch_file
            git --set-upstream origin $e
            e="git --set-upstream origin "$e
            ECHO $S_INFO s "已经git push成功,你使用的git push命令如下："
            echo $e
            ECHO $S_INFO s
            commitFlag=1
            rm  $push_file
            exit 1
        else
            continue
        fi
    done
    echo "commit flag : "+$commitFlag
    if [[ $commitFlag -eq 0 ]];then
        git push
        current_branch_file="current_branch.txt"
        if [ ! -f "$current_branch_file" ];
        then
            touch $current_branch_file
        else
            rm  $current_branch_file
            touch $current_branch_file
        fi
        git branch | grep "*" > $current_branch_file
        cat $current_branch_file | while read  line
        do
            e=$(echo ${line:1:100})
            rm $current_branch_file
            e="git push "$e
            ECHO $S_INFO s "已经git push成功,你使用的git push命令如下："
            echo $e
            ECHO $S_INFO s
            rm  $push_file
            exit 1
        done
    else
        echo "git push failed"
        exit 1
    fi
    )
}


#　函数的功能：运行本地脚本kill_app.sh
function local_run_kill_app_sh
{
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will run local kill_app.sh script"
    ECHO $I_INFO "i" "你将运行本地脚本kill_app.sh"
    ECHO $I_INFO "i"
    cur_dir=$(pwd)
    echo $cur_dir
    cd ~
    cur_dir_home={pwd}
    cd $(pwd)"/code/tp_robot_fst/app"
    ./kill_app.sh > /dev/null
    ./kill_app.sh
    sleep 1
    clear
    cd $cur_dir
}


#　函数的功能：运行本地脚vectioneer_controller.sh
function local_run_vectioneer_controller_sh
{
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will run local vectioneer_controller_shutdown_service.sh script"
    ECHO $I_INFO "i" "你将运行本地脚本vectioneer_controller_shutdown_service.sh"
    ECHO $I_INFO "i"
    cur_dir=$(pwd)
    echo $cur_dir
    cd ~
    cur_dir_home={pwd}
    cd $(pwd)"/code/tp_robot_fst/app/nodes"
    ./vectioneer_controller_shutdown_service.sh
    sleep 1
    cd $cur_dir
}


#　函数的功能：运行本地脚tp_hardware_service_sh
function local_run_tp_hardware_service_sh
{
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will run local tp_hardware_service.sh script"
    ECHO $I_INFO "i" "你将运行本地脚本tp_hardware_service.sh"
    ECHO $I_INFO "i"
    cur_dir=$(pwd)
    echo $cur_dir
    cd ~
    cur_dir_home={pwd}
    cd $(pwd)"/code/tp_robot_fst/app/nodes"
    ./tp_hardware_service.sh
    sleep 1
    clear
    cd $cur_dir
}


#　函数的功能：将develop分支合并到当前分支
function merge_develop_to_current_branch
{
    if [[ $2 != "dp" ]];
    then
        echo "You input format is error, please use ./git_app.sh mg dp"
    fi
    judge_login_user_legality
    git branch |  grep "*" | ( while read  line
    do
        e=$(echo ${line:1:100})
    done
    git stash
    git checkout develop
    git pull
    git checkout $e
    git stash pop stash@{0}
    git merge develop
    ECHO $S_INFO s "合并后的状态如下："
    git status
    ECHO $S_INFO s
    )
}

#　函数的功能：运行本地脚本release.sh
function local_run_release_sh
{
    judge_person=$(judge_current_login_user)
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will run local release.sh script"
    ECHO $I_INFO "i" "你将运行本地脚本release.sh"
    ECHO $I_INFO "i"
    cur_dir=$(pwd)
    cd ~
    cur_dir_home={pwd}
    release_sh_path=$(pwd)"/code/tp_robot_fst/tools/release/"
    cd $release_sh_path
    ./release.sh
    cd $cur_dir
}

#　函数的功能：运行本地脚本kill_app.sh和本地脚本run_all_in_one.sh
function local_run_all_in_one_and_kill_app_sh
{
    local_run_kill_app_sh
    local_run_all_in_one_sh
}

#　函数的功能：运行本地脚本run_all_in_one.sh
function local_run_all_in_one_sh
{
    cur_dir=$(pwd)
    cd ~
    cur_dir_home={pwd}
    cd $(pwd)"/code/tp_robot_fst/app"
    nohup ./run_all_in_one.sh & > /dev/null
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will run run_all_in_one.sh script"
    ECHO $I_INFO "i" "你将运行本地脚本run_all_in_one.sh"
    #ECHO $I_INFO "i" "Wait 13 seconds!!!!     you will see Main interface. "
    ECHO $I_INFO "i" "请等待15s,将会跳转到主界面"
    ECHO $I_INFO "i"
    for (( i=1; i<13; i++));
    do
        if [[ $i == 12 ]];
        then
           echo "第"$i"秒"
           echo "Wait will end!!!"
           sleep 1
           continue
        fi
        echo "第"$i"秒"
        sleep 1
    done
    rm nohup.out
    clear
    cd $cur_dir
}


#　函数的功能：登陆控制器
function login_controller
{
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will login controller"
    ECHO $I_INFO "i" "你将登陆控制器"
    ECHO $I_INFO "i"
    ssh vectioneer@$CONTROLLER_IP_ADDRESS
}


#　函数的功能：重启控制器
function reboot_controller
{
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will reboot controller"
    ECHO $I_INFO "i" "你将重启控制器"
    ECHO $I_INFO "i"
    ip=$CONTROLLER_IP_ADDRESS
    user="vectioneer"
    remote_cmd="/home/vectioneer/reboot.sh"
    port=$CONTROLLER_PORT_NUMBER
    ssh -t -p $port $user@$ip $remote_cmd
}
function controller_run_all_in_one_sh
{
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will run controller script run_all_in_one.sh"
    ECHO $I_INFO "i" "你将运行控制器脚本文件run_all_in_one.sh"
    ECHO $I_INFO "i"
    ip=$CONTROLLER_IP_ADDRESS
    user="vectioneer"
    remote_cmd="cd /home/vectioneer/tp_server/app/ ; sudo ./run_all_in_one.sh"
    echo "$remote_cmd"
    ip=$CONTROLLER_IP_ADDRESS
    user="vectioneer"
    port=$CONTROLLER_PORT_NUMBER
    ssh -t -p $port $user@$ip $remote_cmd

}
function controller_run_kill_app_sh
{
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will run controller script kill_app.sh"
    ECHO $I_INFO "i" "你将运行控制器脚本文件kill_app.sh"
    ECHO $I_INFO "i"
    ip=$CONTROLLER_IP_ADDRESS
    user="vectioneer"
    remote_cmd="cd /home/vectioneer/tp_server/app/ ; sudo ./kill_app.sh"
    port=$CONTROLLER_PORT_NUMBER
    ssh -t -p $port $user@$ip $remote_cmd
}

function copy_tp_server_package_to_controller
{
    judge_person=$(judge_current_login_user)
    ECHO $I_INFO "i"
    #ECHO $I_INFO "i" "You will copy tp_server package to controller"
    ECHO $I_INFO "i" "你将拷贝tp_server压缩包到控制器"
    ECHO $I_INFO "i"
    cur_dir=$(pwd)
    cd ~
    cur_dir_home={pwd}
    package_path=$(pwd)"/code/tp_robot_fst/tools/release/package/*"
    echo $package_path
    scp -r $package_path  vectioneer@$CONTROLLER_IP_ADDRESS:/home/vectioneer
}

function checkout_to_other_branch
{
    judge_person=$(judge_current_login_user)
    judge_login_user_legality
    count=0;
    flag=0
    checkout_char_branch=0
    count_branch_number=0;
    count_all_branch=$(git branch | wc -l)
    local_current_branch=$(git branch | grep "*" | tail -1)
    local_current_branch=$(echo ${local_current_branch#"*"})
    branch_file="branch.txt"
    if [ ! -f "$branch_file" ];
    then
        touch $branch_file
    else
        rm  $branch_file
        touch $branch_file
    fi
    git branch > $branch_file
    cat $branch_file | (while read line
    do
        count=$(($count+1))
        b=$(echo $2 | awk '{print int($0)}')
        if [[ $line =~ "*" ]] ;
        then
            if [[ $count -eq $b ]];
            then
                flag=1
            fi
            break;
        fi
    done
    rm $branch_file
    if [ $flag -eq 1 ];
    then
        ECHO $F_INFO f "不能切换到本分支！！！"
        exit 1
    fi
    flag=0;
    if [[ $2 == *[!0-9]* ]];
    then
        a=$(echo ${2:0:1})
        if [[ $a =~ "-" ]];
        then
            b=$(echo ${2#*"-"})
            if [[ $b == *[0-9]* ]];
            then
                d=$(echo $b | awk '{print int($0)}')
                t=$[count_all_branch+1-count] ;
                if [ $d -eq $t ];
                then
                     ECHO $F_INFO f "不能切换到本分支！！！"
                     exit 1
                fi
                if [ $d -lt $count_all_branch ];
                then
                    ECHO $I_INFO i "你输入的数字在当前分支排序总数范围内"
                else
                    ECHO $F_INFO f "你输入的数字不在当前分支排序总数范围内,请重新输入!!!"
                    exit 1
                fi
            fi
        else
            ECHO $I_INFO i $local_current_branch
            if [[ $2 == $local_current_branch ]];then
                ECHO $F_INFO f "不能切换到当前分支，只能切换到其它分支!!!"
                exit 1
            fi
            git branch |  ( while read line
            do
                if [[ $2 == $line ]];then
                    git branch | grep "*" | while read line
                    do
                        echo $line
                        e=$(echo ${line:1:100})
                        echo $e
                        if [[ $e == $MASTER_BRANCH_BRANCH ]];
                        then
                            #ECHO $I_INFO i "You current branch is:"
                            ECHO $I_INFO i "你当前所在的本地分支为："
                            git branch | grep "*"
                            ECHO $I_INFO i  ""
                            git reset .
                            git checkout -- .
                            git clean -df
                        else
                            if [ $2 -lt 0 ];
                            then
                               d=`expr 0 - $2`
                            else
                               d=$(echo $2 | awk '{print int($0)}')
                            fi
                            #ECHO $I_INFO i "You current branch is:"
                            ECHO $I_INFO i "你当前所在的本地分支为："
                            git branch | grep "*"
                            #ECHO $I_INFO i "You will git stash"
                            ECHO $I_INFO i "你将执行git stash命令,保存本分支的修改记录,再切换分支"
                            git stash
                        fi
                    done
                    git checkout $2
                    checkout_char_branch=1
                fi
            done
            if [ $checkout_char_branch -eq 0 ];
            then
                ECHO $F_INFO f "切换分支失败！没有你想要切换的分支"
            else
                ECHO $S_INFO s "已经成功切换分支"
                git branch
                ECHO $S_INFO s
            fi
            )
            exit 1
        fi
    fi
    git branch | grep "*" | while read line
    do
        echo $line
        e=$(echo ${line:1:100})
        echo $e
        if [[ $e == $MASTER_BRANCH_BRANCH ]];
        then
            #ECHO $I_INFO i "You current branch is:"
            ECHO $I_INFO i "你当前所在的本地分支为："
            git branch | grep "*"
            ECHO $I_INFO i  ""
            git reset .
            git checkout -- .
            git clean -df
        else
            if [ $2 -lt 0 ];
            then
               d=`expr 0 - $2`
            else
               d=$(echo $2 | awk '{print int($0)}')
            fi
            #ECHO $I_INFO i "You current branch is:"
            ECHO $I_INFO i "你当前所在的本地分支为："
            git branch | grep "*"
            #ECHO $I_INFO i "You will git stash"
            ECHO $I_INFO i "你将执行git stash命令,保存本分支的修改记录,再切换分支"
            git stash
        fi
    done
    if [[ $2 -gt $count_all_branch ]];
    then
        git branch | ( while read line
        do
            if [[ $line =~ "#" ]];
            then
                a=$(echo ${line#*#})
                b=$(echo ${a%%_*})
                c=$(echo $b | awk '{print int($0)}')
                if [ $2 -eq $c ];
                then
                    git checkout $line
                    git stash list | while read list
                    do
                        if [[ $list =~ $line ]];
                        then
                            d=$(echo ${list%%:*})
                            git stash pop $d
                            flag=1
                            exit 1
                        fi
                    done
                    #ECHO $S_INFO s "You has checkout branch successfully!!!"
                    ECHO $S_INFO s "已经成功切换分支"
                    git branch
                    ECHO $S_INFO s
                fi
            fi
        done
        if [ $flag -eq 0 ];
        then
            #ECHO $F_INFO f "Checkout branch failure!!!, There is no branch you want to checkout!!!"
            ECHO $F_INFO f "切换分支失败！没有你想要切换的分支"
        fi
        )
    elif [ $2 -le $count_all_branch ] && [ $2 -ge $CHECKOUT_BRANCH_INDEX_MIN ];
    then
        count=0
        git branch | ( while read line
        do
            count=$(($count+1))
            a=$(echo ${line#*#})
            b=$(echo ${a%%_*})
            c=$(echo $b | awk '{print int($0)}')
            if [ $2 -eq $count ];
            then
                git checkout $line
                git stash list | while read list
                do
                    if [[ $list =~ $line ]];
                    then
                        d=$(echo ${list%%:*})
                        git stash pop $d
                        break;
                    fi
                done
                flag=1
                #ECHO $S_INFO s "You has checkout branch successfully!!!"
                ECHO $S_INFO s "已经成功切换分支"
                git branch
                ECHO $S_INFO s
                exit 1
            fi
        done
        if [ $flag -eq 0 ];
        then
            #ECHO $F_INFO f "Checkout branch failure!!!, There is no branch you want to checkout!!!"
            ECHO $F_INFO f "切换分支失败！没有你想要切换的分支"
        fi
        )
    elif [[ $2 -lt $CHECKOUT_BRANCH_INDEX_MIN ]];
    then
        count=0
        count_branch_number=$(git branch | wc -l)
        git branch | (while read line
        do
            count=$(($count+1))
            a=$(echo ${line#*#})
            b=$(echo ${a%%_*})
            c=$(echo $b | awk '{print int($0)}')
            d=$(echo $2 | awk '{print int($0)}')
            e=$((count_branch_number+d+1))
            if [ $e -eq $count ];
            then
                git checkout $line
                git stash list | while read list
                do
                    if [[ $list =~ $line ]];
                    then
                        d=$(echo ${list%%:*})
                        git stash pop $d
                        flag=1
                        exit 1
                        #break;
                    fi
                done
                #ECHO $S_INFO s "You has checkout branch successfully!!!"
                ECHO $S_INFO s "已经成功切换分支"
                git branch
                ECHO $S_INFO s
                exit 1
            fi
        done
        if [ $flag -eq 0 ];
        then
            #ECHO $F_INFO f "Checkout branch failure!!!, There is no branch you want to checkout!!!"
            ECHO $F_INFO f "切换分支失败！没有你想要切换的分支"
        fi
        )
    fi
    )
}

function commit_push_current_modify
{
    judge_person=$(judge_current_login_user)
    judge_login_user_legality
    if [[ $2 != "all" ]];
    then
       echo "You use the ./git_app.sh ap xxx command error!"
       echo "Please use ./git_app.sh mp all"
       exit 1
    fi
    commit_file="commit.txt"
    use_file="use.txt"
    not_track_file="not_track.txt"
    if [ ! -f "$SAVE_MODIFY_FILE" ];
    then
        touch $SAVE_MODIFY_FILE
    else
        rm  $SAVE_MODIFY_FILE
        touch $SAVE_MODIFY_FILE
    fi
    if [ ! -f "$commit_file" ];
    then
        touch $commit_file
    else
        rm  $commit_file
        touch $commit_file
    fi
    git status > $commit_file
    cat $commit_file | while read line
    do
        if [[ $line =~ "git_app.sh" ]];
        then
            git reset git_app.sh
            continue
        else
            if [[ $line =~ "new file:" || $line =~ "modified:" || $line =~ "deleted:" || $line =~ "renamed:" ]];
            then
                e=$(echo ${line:10:100})
                echo $e >> $SAVE_MODIFY_FILE
            elif [[ $line =~ "新文件：" || $line =~ "修改：" || $line =~ "删除：" || $line =~ "重命名：" ]];
            then
                e=$(echo ${line:7:100})
                echo $e >> $SAVE_MODIFY_FILE
            elif [[ $line =~ "git add" ]];
            then
                break
            else
                continue
            fi
        fi
    done
    ECHO $I_INFO i "Already Add file "
    cat  $SAVE_MODIFY_FILE
    ECHO $I_INFO i
    rm $commit_file
    current_branch_file="current_branch.txt"
    if [ ! -f "$current_branch_file" ];
    then
        touch $current_branch_file
    else
        rm  $current_branch_file
        touch $current_branch_file
    fi
    git branch |  grep "*" > $current_branch_file
    cat $current_branch_file | ( while read  line
    do
        e=$(echo ${line:1:100})
        rm $current_branch_file
        judge_string=$(echo ${line:12:3})
        if [ "$judge_string" -gt 0 ] 2>/dev/null ;then
            #commit_message=`echo $e | cut -d \# -f 2`
            commit_message=$(echo ${e:10:100})
            commit_message=${commit_message//_/" "};
            commit_message=$judge_person" ""issue:#"$commit_message
            ECHO $S_INFO s "commit message"
            echo $commit_message
            ECHO $S_INFO s
            git commit  -m "$commit_message"
        else
            commit_message=$(echo ${e:9:100})
            commit_message=${commit_message//_/" "};
            commit_message=$judge_person" "$commit_message
            ECHO $S_INFO s "commit message"
            echo $commit_message
            ECHO $S_INFO s
            git commit  -m "$commit_message"
        fi
        done
    )
    rm $SAVE_MODIFY_FILE
    push_file="push.txt"
    if [ ! -f "push_file" ];
    then
        touch $push_file
    else
        rm  $push_file
        touch $push_file
    fi
    git push 2> $push_file
    cat $push_file
    cat $push_file | ( while read line
    do
        if [[ $line =~ "--set-upstream" ]];then
            cmd=$line
            $cmd
            #ECHO $S_INFO s "You have push successfully!!! The push command is : "
            ECHO $S_INFO s "你已经git push成功,使用的git push命令是："
            echo $line
            ECHO $S_INFO s
            commitFlag=1
            rm  $push_file
            exit 1
        elif [[ $line =~ "push origin" ]];
        then
            if [[ $line =~ "HEAD:" ]];
            then
                continue
            else
                cmd=$line
                $cmd
                #ECHO $S_INFO s "You have push successfully!!! The push command is : "
                ECHO $S_INFO s "你已经git push成功,使用的git push命令是："
                echo $line
                ECHO $S_INFO s
                commitFlag=1
                rm  $push_file
                exit 1
            fi
        elif [[ $line =~ "Everything up-to-date" ]];then
            current_branch_file="current_branch.txt"
            if [ ! -f "$current_branch_file" ];
            then
                touch $current_branch_file
            else
                rm  $current_branch_file
                touch $current_branch_file
            fi
            git branch | grep "*" > $current_branch_file
            cat $current_branch_file | while read  line
            do
                e=$(echo ${line:1:100})
            done
            rm $current_branch_file
            git --set-upstream origin $e
            e="git --set-upstream origin "$e
            #ECHO $S_INFO s "You have push successfully!!! The push command is : "
            ECHO $S_INFO s "你已经git push成功,使用的git push命令是："
            echo $e
            ECHO $S_INFO s
            commitFlag=1
            rm  $push_file
            exit 1
        else
            continue
        fi
    done
    echo "commit flag : "+$commitFlag
    if [[ $commitFlag -eq 0 ]];then
        git push
        current_branch_file="current_branch.txt"
        if [ ! -f "$current_branch_file" ];
        then
            touch $current_branch_file
        else
            rm  $current_branch_file
            touch $current_branch_file
        fi
        git branch | grep "*" > $current_branch_file
        cat $current_branch_file | while read  line
        do
            e=$(echo ${line:1:100})
            e="git push "$e
            #ECHO $S_INFO s "You have push successfully!!! The push command is : "
            ECHO $S_INFO s "你已经git push成功,使用的git push命令是："
            echo $e
            ECHO $S_INFO s
            rm  $push_file
            rm $current_branch_file
            exit 1
        done
    else
        #echo "git push failed"
        ECHO $F_INFO f "你已经git push失败,请重新git push"
        exit 1
    fi
    )
}

function add_commit_push_current_modify_with_message
{
    judge_person=$(judge_current_login_user)
    judge_login_user_legality
    use_file="use.txt"
    if [ ! -f "$SAVE_MODIFY_FILE" ];
    then
        touch $SAVE_MODIFY_FILE
    else
        rm  $SAVE_MODIFY_FILE
        touch $SAVE_MODIFY_FILE
    fi
    hasAdd_file="hasAdd.txt"
    if [ ! -f "$HAS_GIT_ADD_FILE" ];
    then
        touch $HAS_GIT_ADD_FILE
    else
        rm  $HAS_GIT_ADD_FILE
        touch $HAS_GIT_ADD_FILE
    fi
    commitFlag=0
    addFileFlag=0
    not_track_file="not_track.txt"
    git status | while read line
    do
        if [[ $line =~ "git reset HEAD" ]];
        then
            addFileFlag=1
            continue
        elif [[ $addFileFlag == 1 ]];
        then
            if [[ $line =~ "git add"  ]];
            then
                addFileFlag=0
                continue
            else
                if [[ $line =~ "new file:" || $line =~ "modified:" || $line =~ "deleted:" || $line =~ "renamed:" ]];
                then
                    e=$(echo ${line:10:100})
                    echo $e >> $HAS_GIT_ADD_FILE
                elif [[ $line =~ "新文件：" || $line =~ "修改：" || $line =~ "删除：" || $line =~ "重命名：" ]];
                then
                    e=$(echo ${line:7:100})
                    echo $e >> $HAS_GIT_ADD_FILE
                else
                    continue
                fi
            fi
        elif [[ $addFileFlag == 0 ]];
        then
            if [[ $line =~ "new file:" || $line =~ "modified:" || $line =~ "deleted:" || $line =~ "renamed:" ]];
            then
                e=$(echo ${line:10:100})
                echo $e >> $SAVE_MODIFY_FILE
            elif [[ $line =~ "新文件：" || $line =~ "修改：" || $line =~ "删除：" || $line =~ "重命名：" ]];
            then
                e=$(echo ${line:7:100})
                echo $e >> $SAVE_MODIFY_FILE
            else
                continue
            fi
        fi
    done
    git clean -ndf  | while read line
    do
        if [[ $line =~ "use.txt" || $line =~ "hasAdd.txt" ]];
        then
            continue
        elif [[ $line =~ "Would remove" ]];
        then
            e=$(echo ${line:10:100})
            echo $e >> $SAVE_MODIFY_FILE
        elif [[ $line =~ "将删除" ]];
        then
            e=$(echo ${line:4:100})
            echo $e >> $SAVE_MODIFY_FILE
        else
            continue
        fi
    done

    want_push_file="want_push_file.txt"
    if [ ! -f "$WANT_PUSH_FILE" ];
    then
        touch $WANT_PUSH_FILE
    else
        rm  $WANT_PUSH_FILE
        touch $WANT_PUSH_FILE
    fi
    count=1
    cat $SAVE_MODIFY_FILE | while read line
    do
        for arg in "$@"
        do
            if [[ $arg == *[!0-9]* ]];
            then
                continue
            elif [ $arg -eq $count ];
            then
                if [[ $line =~ "git_app.sh" ]];
                then
                    continue
                else
                    git add $line
                    echo $line >> $WANT_PUSH_FILE
                fi
            fi
        done
         count=$(($count+1))
    done
    rm $SAVE_MODIFY_FILE

    if [ -s $HAS_GIT_ADD_FILE ];
    then
        ECHO $I_INFO i "已经git add的文件"
        cat $HAS_GIT_ADD_FILE
        rm $HAS_GIT_ADD_FILE
        ECHO $I_INFO i
    else
        rm $HAS_GIT_ADD_FILE
    fi
    ECHO $I_INFO i "即将git add的文件"
    cat  $WANT_PUSH_FILE
　　ECHO $I_INFO i
    rm $WANT_PUSH_FILE
    current_branch_file="current_branch.txt"
    if [ ! -f "$current_branch_file" ];
    then
        touch $current_branch_file
    else
        rm  $current_branch_file
        touch $current_branch_file
    fi

    git branch |  grep "*" > $current_branch_file
    cat $current_branch_file | ( while read  line
    do
        e=$(echo ${line:1:100})
        rm $current_branch_file
        ECHO $S_INFO s "你添加的git commit信息"
        echo $2
        ECHO $S_INFO s
        git commit  -m "$2"
    done
    )
    push_file="push.txt"
    if [ ! -f "push_file" ];
    then
        touch $push_file
    else
        rm  $push_file
        touch $push_file
    fi
    git push 2> $push_file
    cat $push_file
    cat $push_file | ( while read line
    do
        if [[ $line =~ "--set-upstream" ]];then
            cmd=$line
            $cmd
            ECHO $S_INFO s "你已经git push成功,使用的git push命令是："
            echo $line
            ECHO $S_INFO s
            commitFlag=1
            rm  $push_file
            exit 1
        elif [[ $line =~ "push origin" ]];
        then
            if [[ $line =~ "HEAD:" ]];
            then
                continue
            else
                cmd=$line
                $cmd
                ECHO $S_INFO s "你已经git push成功,使用的git push命令是："
                echo $line
                ECHO $S_INFO s
                commitFlag=1
                rm  $push_file
                exit 1
            fi
        elif [[ $line =~ "Everything up-to-date" ]];then
            current_branch_file="current_branch.txt"
            if [ ! -f "$current_branch_file" ];
            then
                touch $current_branch_file
            else
                rm  $current_branch_file
                touch $current_branch_file
            fi
            git branch | grep "*" > $current_branch_file
            cat $current_branch_file | while read  line
            do
                e=$(echo ${line:1:100})
            done
            rm $current_branch_file
            git --set-upstream origin $e
            ECHO $S_INFO s "你已经git push成功,使用的git push命令是："
            echo "git --set-upstream origin "+$e
            ECHO $S_INFO s
            commitFlag=1
            rm  $push_file
            exit 1
        else
            continue
        fi
    done
    echo "commit flag : "+$commitFlag
    if [[ $commitFlag -eq 0 ]];then
        git push
        current_branch_file="current_branch.txt"
        if [ ! -f "$current_branch_file" ];
        then
            touch $current_branch_file
        else
            rm  $current_branch_file
            touch $current_branch_file
        fi
        git branch | grep "*" > $current_branch_file
        cat $current_branch_file | while read  line
        do
            e=$(echo ${line:1:100})
            rm $current_branch_file
            ECHO $S_INFO s "你已经git push成功,使用的git push命令是："
            echo "git push "$e
            ECHO $S_INFO s
            rm  $push_file
            exit 1
        done
    else
        echo "git push failed"
        exit 1
    fi
    )
}

if [ $# -lt 1 ];
then
    git_app_help
elif [ $# -lt 2 ];
then
    if [ $1 == "h" ] || [ $1 == "-h" ] || [ $1 == "help" ];
    then
        git_app_help
    elif [ $1 == "v" ] || [ $1 == "-v" ] || [ $1 == "version" ];
    then
        git_app_version
    elif [ $1 == "b" ] || [ $1 == "-b" ] || [ $1 == "branch" ];
    then
        git branch
    elif [ $1 == "s" ] || [ $1 == "-s" ] || [ $1 == "status" ];
    then
        git status
    elif [ $1 == "r" ] ;
    then
        local_run_all_in_one_sh
    elif [ $1 == "k" ];
    then
        local_run_kill_app_sh
    elif [ $1 == "kr" ];
    then
        local_run_all_in_one_and_kill_app_sh
    elif [ "$1" == "rl" ];
    then
        local_run_release_sh $*
    elif [ "$1" == "th" ];
    then
        local_run_tp_hardware_service_sh $*
    elif [ "$1" == "cv" ];
    then
        local_run_vectioneer_controller_sh $*
    elif [ "$1" == "nt" ];
    then
        open_new_terminal
    elif [ "$1" == "cp" ];
    then
        copy_tp_server_package_to_controller $*
    elif [ $1 == "ctr" ];
    then
        controller_run_all_in_one_sh
    elif [ $1 == "ctk" ];
    then
        controller_run_kill_app_sh
    elif [ "$1" == "ctl" ];
    then
        login_controller
    elif [ "$1" == "bt" ];
    then
        open_bitbucket
    elif [ "$1" == "em" ];
    then
        open_ali_email
    elif [ "$1" == "bd" ];
    then
        open_baidu
    elif [ "$1" == "pc" ];
    then
        open_pycharm
    elif [ "$1" == "ctb" ];
    then
        reboot_controller
    elif [ "$1" == "grpo" ];
    then
        git_remote_prune_origin
    elif [ "$1" == "gcho" ];
    then
        git_clean_and_checkout
    else
        echo "You input wrong format,please ./git_app.sh  !"
    fi
elif [ $# -ge 2 ];
then
    judge_command_message=$1
    length_string=${#judge_command_message}
    if [ "$1" == "cb" ];
    then
        create_new_branch $*
    elif [ "$1" == "ch" ];
    then
        checkout_to_other_branch $*
    elif [ $1 == "dld" ] || [ $1 == "dli" ];
    then
        delete_local_branch $*
    elif [ $1 == "dod" ] || [ $1 == "doi" ];
    then
        delete_origin_branch $*
    elif [ $1 == "mg" ];
    then
        merge_develop_to_current_branch
    elif [ "$1" == "acp" ];
    then
        add_commit_push_current_modify $*
    elif [ "$1" == "mp" ];
    then
        commit_push_current_modify $*
    elif [ "$1" == "am" ];
    then
        add_commit_current_modify $*
    else
        echo "your command format is wrong!"
    fi
fi
