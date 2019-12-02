#!/bin/bash
function jianfa() {
    a=$(shuf -i 1-9 -n1) && b=$(shuf -i 1-9 -n1)
    m=$(echo $a $b | tr ' ' '\n' | sort -n | tail -n1)
    n=$(echo $a $b | tr ' ' '\n' | sort -n | head -n1)
    suansi[i]="$m-$n="
    ans[i]=$((m-n))
}

function JIAFA() {
    m=$(shuf -i 1-9 -n1)
    n=$(($(($RANDOM%$((10-m))))+1))
    suansi[i]="$m+$n="
    ans[i]=$((m+n))
}

function main() {
    read -p "这次想挑战多少题目:" num </dev/tty
    for ((i=0; i<num; i++)); do
        pick=$(shuf -i 1-2 -n1)
        [[ $pick == 1 ]] && jianfa || JIAFA
        echo ${suansi[i]}
        read -p "以上题目的答案是:" inputans </dev/tty
        [[ $inputans == ${ans[i]} ]] && echo 答对了，继续加油哟 || i=$((i-1))
    done
    
    echo "挑战成功，太棒了！这次已经答对了$i道题目了，休息一下吧！"
}

main

#TODO
#乘除法
#自定义算式数字大小范围
#错误率过高则挑战失败
#错题回顾
