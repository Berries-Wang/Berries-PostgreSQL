#!/bin/bash
set -e
CURDIR=`pwd`
cd ${CURDIR}/..
# 注意: 数据库集簇(003.DATADIR/DATA)也在 000.build-output 里,下面这条 rm 会连同数据一起删掉,重编译前请先备份数据
rm -rf 000.build-output && mkdir 000.build-output && cd 000.build-output && mkdir 000.PREFIX 001.EXEC_PREFIX 002.BIN_DIR 003.DATADIR
./../002.PostgreSQL-16.2/configure \
   --prefix=${CURDIR}/../000.build-output/000.PREFIX \
   --exec-prefix=${CURDIR}/../000.build-output/001.EXEC_PREFIX \
   --bindir=${CURDIR}/../000.build-output/002.BIN_DIR \
   --datadir=${CURDIR}/../000.build-output/003.DATADIR \
   --with-ssl=openssl

# 编译: world-bin = 核心服务端 + 全部 contrib 扩展模块(pgcrypto/pg_trgm/hstore/postgres_fdw 等)
# 不用 world: world 额外编译 HTML 文档,需要安装 docbook 工具链
make -j$(nproc) world-bin

# 安装: 到指定的目录(含全部 contrib 扩展模块)
make install-world-bin

# 初始化数据库
# ./initdb -D  000.SOURCE_CODE/PostgreSQL-16.2/001.build-script/003.DATA
echo '编译&安装完成'
