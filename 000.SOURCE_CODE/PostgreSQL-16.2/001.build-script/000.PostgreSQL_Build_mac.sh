#!/bin/bash
set -e
CURDIR=`pwd`
cd ${CURDIR}/..
rm -rf 000.build-output && mkdir 000.build-output && cd 000.build-output && mkdir 000.PREFIX 001.EXEC_PREFIX 002.BIN_DIR 003.DATADIR

# PostgreSQL 16 起 ICU 默认为必选依赖;Homebrew 的 icu4c 是 keg-only,
# 不会出现在 pkg-config 默认搜索路径里,必须手动指定
export PKG_CONFIG_PATH="$(brew --prefix icu4c)/lib/pkgconfig:${PKG_CONFIG_PATH}"
./../002.PostgreSQL-16.2/configure \
   --prefix=${CURDIR}/../000.build-output/000.PREFIX \
   --exec-prefix=${CURDIR}/../000.build-output/001.EXEC_PREFIX \
   --bindir=${CURDIR}/../000.build-output/002.BIN_DIR \
   --datadir=${CURDIR}/../000.build-output/003.DATADIR \
   --with-ssl=openssl \
   --with-includes="$(brew --prefix openssl@3)/include" \
   --with-libraries="$(brew --prefix openssl@3)/lib"

# 编译
make all

# 安装: 到指定的目录
make install 

# 初始化数据库
# ./initdb -D  000.SOURCE_CODE/PostgreSQL-16.2/001.build-script/003.DATA
echo '编译&安装完成'


