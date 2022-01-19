#!/bin/bash

# api_token
api_token=''
function get_joplin_token(){
    api_token=$(cat /home/node/.config/joplin/settings.json | jq -r '."api.token"')
}

cursor=-1
get_cursor(){
    url="http://localhost:41184/events?token=$api_token"
    ret=$(curl $url | jq '.cursor')
    echo $ret
}



# 初始化工作，以node权限运行

# 设置 joplin
joplin config sync.target ${SYNC_TARGET}
joplin config sync.${SYNC_TARGET}.path ${SYNC_PATH} 
joplin config sync.${SYNC_TARGET}.username ${SYNC_USERNAME} 
joplin config sync.${SYNC_TARGET}.password ${SYNC_PASSWORD} 
joplin config api.port 41184

# 设置git
git config --global user.name ${GIT_USER}
git config --global user.email ${GIT_EMAIL}

# git clone blog
if [ ! -d "blog" ]; then
    git clone ${BLOG_REPOSITORY} /home/node/.config/blog
    cd blog
else
    cd blog
    git pull
fi

# 添加依赖
yarn add -D joplin-blog
cnpm install hexo-deployer-git --save
cnpm install -D md5 moment request xml-parser
cnpm install -S hexo-generator-sitemap
cnpm install


# 初始化 .joplin-blog.json
if [ ! -f '.joplin-blog.json' ]; then

    get_joplin_token
    echo 'token:'$api_token

    touch '.joplin-blog.json'

    echo '{' >> '.joplin-blog.json'
    echo '  "type": "hexo", ' >> '.joplin-blog.json'
    echo '  "language": "en",' >> '.joplin-blog.json'
    echo '  "rootPath": ".",' >> '.joplin-blog.json'
    echo '  "joplinProfilePath": "/home/node/.config/joplin",' >> '.joplin-blog.json'
    echo '  "token": "'$api_token'",' >> '.joplin-blog.json'
    echo '  "port": 41184,' >> '.joplin-blog.json'
    echo '  "tag": "'${BLOG_TAG}'"' >> '.joplin-blog.json'
    echo '}' >> '.joplin-blog.json'
    echo '' >> '.joplin-blog.json'
fi


# 初始化 .joplin-blog.json
if [ ! -f '.joplin-blog.json' ]; then

    get_joplin_token
    echo 'token:'$api_token

    touch '.joplin-blog.json'

    echo '{' >> '.joplin-blog.json'
    echo '  "type": "hexo", ' >> '.joplin-blog.json'
    echo '  "language": "en",' >> '.joplin-blog.json'
    echo '  "rootPath": ".",' >> '.joplin-blog.json'
    echo '  "joplinProfilePath": "/home/node/.config/joplin",' >> '.joplin-blog.json'
    echo '  "token": "'$api_token'",' >> '.joplin-blog.json'
    echo '  "port": 41184,' >> '.joplin-blog.json'
    echo '  "tag": "'${BLOG_TAG}'"' >> '.joplin-blog.json'
    echo '}' >> '.joplin-blog.json'
    echo '' >> '.joplin-blog.json'
fi

# 启动服务
echo start service
joplin server start &



do_update() {

    git reset --hard
    git pull

    echo 开始同步joplin...
    joplin sync
    echo 同步完成

    new_cursor=$(get_cursor)
    echo "current cursor: $new_cursor"
    if [[ $new_cursor -gt $cursor  ]]; then
        cursor=$new_cursor

        echo 生成博客...
        yarn gen
        echo 生成完成

        echo 发布到仓库...
        git add .
        git commit -m \"commit $(date)\"
        git push origin main
        echo 发布完成
    else
        echo 笔记没有更新，跳过笔记同步
    fi

    echo 发布到hexo
    yarn build
    yarn deploy
    echo 发布完成
}

while true; do do_update; sleep ${SYNC_TIME_INTERVAL}; done

