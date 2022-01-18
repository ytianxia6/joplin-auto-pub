#!/bin/bash

# api_token=''
# function get_joplin_token(){
#     api_token=$(cat /home/node/.config/joplin/settings.json | jq -r '."api.token"')
# }

# 生成id_rsa
if [ ! -f /home/node/.ssh/id_rsa ]; then
    cp /root/.ssh/id_rsa /home/node/.ssh/id_rsa
    chown -R node:node /home/node/.ssh/id_rsa
    chmod 400 /home/node/.ssh/id_rsa
    cat << EOF >> /home/node/.ssh/config
        User node
EOF
fi

# 确认目录权限
chown -R node:node /home/node/.config

# 准备目录
if [ ! -d /home/node/.config/joplin ]; then
    mkdir -p /home/node/.config/joplin
    chown -R node:node /home/node/.config/joplin
fi

# ln -s /run/secrets/id_rsa /home/node/.ssh/id_rsa

# # 初始化
# # 设置同步
# su node -c "joplin config sync.target ${SYNC_TARGET}"
# su node -c "joplin config sync.${SYNC_TARGET}.path ${SYNC_PATH} "
# su node -c "joplin config sync.${SYNC_TARGET}.username ${SYNC_USERNAME} "
# su node -c "joplin config sync.${SYNC_TARGET}.password ${SYNC_PASSWORD} "
# su node -c "joplin config api.port 41184"
# # joplin sync

# su node -c "git config --global user.name ${GIT_USER}"
# su node -c "git config --global user.email ${GIT_EMAIL}"

# touch /home/node/.ssh/known_hosts
# ssh-keyscan github.com >> /home/node/.ssh/known_hosts

# 初始化blog
# if [ ! -d "blog" ]; then
    
#     su node -c "git clone ${BLOG_REPOSITORY} /home/node/.config/blog"
#     chown -R node:node /home/node/.config/blog

# fi

# cd blog
# su node -c "git pull"


# # 添加依赖
# su node -c "yarn add -D joplin-blog"
# su node -c "cnpm install hexo-deployer-git --save"
# su node -c "cnpm install"

# # 初始化 .joplin-blog.json
# if [ ! -f '.joplin-blog.json' ]; then

#     get_joplin_token
#     echo 'token:'$api_token

#     su node -c "touch '.joplin-blog.json'"

#     echo '{' >> '.joplin-blog.json'
#     echo '  "type": "hexo", ' >> '.joplin-blog.json'
#     echo '  "language": "en",' >> '.joplin-blog.json'
#     echo '  "rootPath": ".",' >> '.joplin-blog.json'
#     echo '  "joplinProfilePath": "/home/node/.config/joplin",' >> '.joplin-blog.json'
#     echo '  "token": "'$api_token'",' >> '.joplin-blog.json'
#     echo '  "port": 41184,' >> '.joplin-blog.json'
#     echo '  "tag": "'${BLOG_TAG}'"' >> '.joplin-blog.json'
#     echo '}' >> '.joplin-blog.json'
#     echo '' >> '.joplin-blog.json'
# fi

# cursor
# cursor=-1

# get_cursor(){
#     url="http://localhost:41184/events?token=$api_token"
#     ret = curl $url | jq '.cursor'
#     echo ret
# }




# # 启动服务
# echo start service
# su node -c "joplin server start &"

# do_update() {

#     su node -c "git pull"

#     new_cursor=$(get_cursor)
#     if [ $new_cursor -gt $cursor  ]; then
#         new_cursor=$cursor
#         echo begin sync
#         su node -c "joplin sync"
#         echo end sync

#         echo begin update blog
#         su node -c "yarn gen"
#         echo complete update

#         echo push github
#         su node -c "git add ."
#         su node -c "git commit -m \"commit $(date)\""
#         su node -c "git push origin main"
#         echo push github complete
#     else
#         echo 笔记没有更新，跳过笔记同步
#     fi

#     echo do publish...
#     su node -c "yarn build"
#     su node -c "yarn deploy"
#     echo complete publish
# }


# while true; do do_update; sleep ${SYNC_TIME_INTERVAL}; done

su node -c "init.sh"