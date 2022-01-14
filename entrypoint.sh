#!/bin/bash

api_token=''
function get_joplin_token(){
    api_token=$(cat /home/node/.config/joplin/settings.json | jq -r '."api.token"')
}

# 准备目录
if [ ! -d /home/node/.config/joplin ]; then
    mkdir -p /home/node/.config/joplin
    chown -R node:node /home/node/.config/joplin
fi

# 初始化
# 设置同步
su node -c "joplin config sync.target ${SYNC_TARGET}"
su node -c "joplin config sync.${SYNC_TARGET}.path ${SYNC_PATH} "
su node -c "joplin config sync.${SYNC_TARGET}.username ${SYNC_USERNAME} "
su node -c "joplin config sync.${SYNC_TARGET}.password ${SYNC_PASSWORD} "
su node -c "joplin config api.port 41184"
# joplin sync

su node -c "git config --global user.name ${GIT_USER}"
su node -c "git config --global user.email ${GIT_EMAIL}"

# touch /home/node/.ssh/known_hosts
# ssh-keyscan github.com >> /home/node/.ssh/known_hosts

# 初始化blog
if [ ! -d "blog" ]; then
    
    git clone ${BLOG_REPOSITORY} /home/node/.config/blog
    chown -R node:node /home/node/.config/blog

fi

cd blog
su node -c "git pull"


# 添加依赖
su node -c "yarn add -D joplin-blog"
su node -c "cnpm install hexo-deployer-git --save"
su node -c "cnpm install"

# 初始化 .joplin-blog.json
if [ ! -f '.joplin-blog.json' ]; then

    get_joplin_token
    echo 'token:'$api_token

    su node -c "touch '.joplin-blog.json'"

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
su node -c "joplin server start &"

do_update() {
    echo 开始同步
    su node -c "joplin sync"
    echo 同步完成

    echo 开始更新blog
    su node -c "yarn gen"
    echo 更新完成

    echo 开始上传到github
    su node -c "git add ."
    su node -c "git commit -m "自动发布 $(date)"
    su node -c "git push origin main"
    echo 上传完成

    echo 开始发布
    su node -c "yarn build"
    su node -c "yarn deploy"
    echo 发布完成
}

echo "同步成功！"
while true; do do_update; sleep ${SYNC_TIME_INTERVAL}; done

