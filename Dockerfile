# 使用DaoCloud的Ubuntu镜像,bella改为16.04
FROM daocloud.io/library/ubuntu:16.04

# 设置镜像作者
MAINTAINER Fundebug <help@fundebug.com>


# 配置中文语言
ENV LANGUAGE zh_CN.UTF-8
ENV LANG zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
RUN /usr/share/locales/install-language-pack zh_CN \
  && locale-gen zh_CN.UTF-8 \
  && dpkg-reconfigure --frontend noninteractive locales \
  && apt-get -qqy --no-install-recommends install language-pack-zh-hans
  # 安装基本字体
RUN apt-get -qqy --no-install-recommends install \
    fonts-ipafont-gothic \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    xfonts-scalable

# 安装文泉驿微米黑字体
RUN apt-get -qqy install ttf-wqy-microhei \
  && ln /etc/fonts/conf.d/65-wqy-microhei.conf /etc/fonts/conf.d/69-language-selector-zh-cn.conf

# 使用阿里云的Ubuntu镜像
RUN echo '\n\
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse\n\
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse\n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse\n'\
> /etc/apt/sources.list

# 安装node v6.10.1
RUN  apt-get update &&  apt-get install -y wget



  #============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://raw.githubusercontent.com/bellajun/node-firefox-debug-zh/master/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
&& rm -rf /var/lib/apt/lists/* /var/cache/apt/*


# 使用淘宝镜像安装Node.js v6.10.1，bella改为latest v10.0.0版本
RUN wget https://npm.taobao.org/mirrors/node/latest/node-v10.0.0-linux-x64.tar.gz  && \
    tar -C /usr/local --strip-components 1 -xzf node-v10.0.0-linux-x64.tar.gz  && \
    rm node-v10.0.0-linux-x64.tar.gz  && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs

#ENV TZ "Asia/Shanghai"
#RUN  echo "${TZ}" > /etc/timezone   && dpkg-reconfigure --frontend noninteractive tzdata
  
# 设置时区
#ENV TZ "PRC"
#RUN echo "Asia/Shanghai" | tee /etc/timezone   && dpkg-reconfigure --frontend noninteractive tzdata

WORKDIR /app

# 安装npm模块
ADD package.json /app/package.json

# 使用淘宝的npm镜像
RUN npm install --production -d --registry=https://registry.npm.taobao.org
#bella add，安装puppeteer，jest
RUN npm install --save puppeteer@1.4.0
RUN npm install --save jest
# 添加源代码
#ADD . /app

# 运行app.js
#CMD ["node", "/app/app.js"]
CMD [ "node" ]
