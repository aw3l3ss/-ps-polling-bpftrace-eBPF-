#!/bin/bash
# Часть 1: опрос ps в цикле, подсчёт процессов, появившихся за DURATION секунд

DURATION=${1:-10}
snap=$(mktemp)
declare -A old new

# процессы, которые уже были до старта, не считаем
ps -e -o pid=,ppid=,args= > "$snap"
for pid in $(awk '{print $1}' "$snap"); do old[$pid]=1; done

end=$((SECONDS + DURATION))
while [ $SECONDS -lt $end ]; do
    ps -e -o pid=,ppid=,args= > "$snap"
    # убираем ядерные потоки ([имя]) и сам ps, запущенный этим скриптом
    for pid in $(awk -v me=$$ '$2 != me && $3 !~ /^\[/ {print $1}' "$snap"); do
        [ -z "${old[$pid]}" ] && new[$pid]=1
    done
done

rm -f "$snap"
echo "ps увидел новых процессов за $DURATION с: ${#new[@]}"
