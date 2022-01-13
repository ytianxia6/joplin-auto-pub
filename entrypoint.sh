#!/bin/bash

api_token=''
function get_joplin_token(){
    api_token=$(cat /home/node/.config/joplin/settings.json | jq -r '."api.token"')
}


# 初始化
# 设置同步
joplin config sync.target "${SYNC_TARGET}"
joplin config sync.${SYNC_TARGET}.path ${SYNC_PATH} 
joplin config sync.${SYNC_TARGET}.username ${SYNC_USERNAME} 
joplin config sync.${SYNC_TARGET}.password ${SYNC_PASSWORD} 
joplin config api.port 41184
# joplin sync

git config --global user.name ${GIT_USER}
git config --global user.email ${GIT_EMAIL}

# touch /home/node/.ssh/known_hosts
# ssh-keyscan github.com >> /home/node/.ssh/known_hosts

# 初始化blog
if [ ! -d "blog" ]; then
    git clone ${BLOG_REPOSITORY} blog

fi

cd blog
git pull


# 添加依赖
yarn add -D joplin-blog
cnpm install hexo-deployer-git --save
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
    echo '  "tag": "blog"' >> '.joplin-blog.json'
    echo '}' >> '.joplin-blog.json'
    echo '' >> '.joplin-blog.json'
fi



# 启动服务
echo 启动服务
joplin server start &

do_update() {
    echo 开始同步
    joplin sync;
    echo 同步完成

    echo 开始更新blog
    yarn gen
    echo 更新完成

    echo 开始上传到github
    git add .
    git commit -m "自动发布 $(date)"
    git push origin main
    echo 上传完成

    echo 开始发布
    yarn build
    yarn deploy
    echo 发布完成
}

echo "同步成功！"
while true; do do_update; sleep ${SYNC_TIME_INTERVAL}; done

