#!/bin/bash
# 在git commit 后 使用此脚本

# usage: bash publish.sh <commit_text>
# commit_text 是可选项
# 当提交后又有了更改，那么会git add . 并且git commit -m "commit_text"
# 如果commit_text为空，那么将简单粗暴的把git status -s的内容作为commit_text来提交


# 写markdown的时候，插入图片时肯定会写上图片链接（如：![img](../posts/2020/02/17/image.png)），但是jekyll在解析图片的时候，默认会到../posts/year/month/day中去找图片，所以在上面的例子中写成![img](image.png)这样才能解析成功，所以需要删除目录

# 遍历被更改的md文件
for i in $(git status -s | grep "_posts/.*md" | awk 'BEGIN{OFS=" "}{print $NF}')
do 
	#把每个文件中，涉及到插入图片的行的行号提取出来(用匹配![*](*)来实现)
	cat ${i} | grep -n "\!\[.*\](.*)" | cut -d ":" -f 1 | while read line 
	do 
		#循环，把上面提取出来的行号涉及到的行，删除路径
		sed -i "${line}s/..\/posts\/[0-9]*\/[0-9]*\/[0-9]*\///g" ${i} 
	done 
done


# 如果已经提交并且没有在提交后再有新的更改，那么执行push
if [[ $(git status -s) == "" ]];then 
	git push myblog master
else
# 在提交后再有新的更改，那么执行git add . 并且提交，然后再push

	# 如果commit_text没有被提供，那么以git status -s 为commit_text
	if [[ $1 == "" ]];then
		commit_text=$(git status -s)
	# 如果commit_text被提供了，那么用提供的commit_text
	else
		commit_text=$1
	fi

	git add . && git commit -m "$commit_text"
	git push myblog master
fi


