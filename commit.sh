#!/usr/bin/env bash

Help()
{
   echo "你也可以使用自定义参数进行指定查询"
   echo
   echo "格式: bash $0 [2022-01-01] [2022-04-04] [author]"
   echo "示例: bash commit.sh 2022-01-01 2022-12-31 digua"
   echo "参数:"
   echo "1st     分析的起始时间."
   echo "2nd     分析的结束时间."
   echo "3rd     指定提交用户，可以是 name 或 email."
   echo
}

time_start=$1

if [[ "$1" == "--help" ]]
    then
        Help
        exit 0
elif [[ "$1" == "-h" ]]
    then
        Help
        exit 0
fi

if [[ -z "$1" ]]
    then
        time_start="2022-01-01"
fi

time_end=$2
if [[ -z "$2" ]]
    then
        time_end=$(date "+%Y-%m-%d")
fi

author=$3
if [[ -z "$3" ]]
    then
        author=""
fi

RED='\033[1;91m'
NC='\033[0m' # No Color

echo -e "${RED}统计时间范围：$time_start 至 $time_end${NC}"

# 一周七天提交分布
echo
echo -e "${NC}一周七天 commit 分布${RED}"
git log --author="$author" --pretty=format:"%ad" --date=format:%u --after="$time_start" --before="$time_end" |
sort | uniq -c |
awk '{printf "%s\t星期%s\n", $1, $2}' |
column -t

# 24小时提交分布
echo
echo -e "${NC}24小时 commit 分布${RED}"
git log --author="$author" --pretty=format:"%ad" --date=format:%H --after="$time_start" --before="$time_end" |
sort | uniq -c |
awk '{printf "%s\t%s点\n", $1, $2}' |
column -t

# 夜间提交最多的作者 Top 5
echo
echo -e "${NC}晚上9点到早上7点提交最多的作者 Top 20:${RED}"
git log --author="$author" --pretty=format:"%an %H" --date=format:%H --after="$time_start" --before="$time_end" |
awk '{
    hour = $2 + 0
    if (hour >= 21 || hour < 7) {
        author_count[$1]++
    }
}
END {
    for (author in author_count) {
        print author_count[author], author
    }
}' | sort -rn | head -n 20
echo -e "${NC}"
