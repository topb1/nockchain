#!/bin/bash

############################################
## 作者:       0x13904b 
## Twitter|X: https://x.com/0x13904b
## Telegram:  https://t.me/twitter_0x13904b
############################################

source .env
export MINING_PUBKEY

# Check for help flag and parse arguments for starting node index
NUM_NODES=1
START_INDEX=1

if [ "$1" = "-h" -o "$1" = "--help" ]; then
  echo "当前.env配置的公钥为:\n$MINING_PUBKEY"
  echo "**** 请确认此公钥是否为你的公钥，如果不是请将.env文件中的公钥改为自己 ****"
  echo ""
  echo "使用方法:  sh $0 [启动节点数量] [起始节点编号]"
  echo "使用示例:  sh $0 10 5   # 表示启动10个节点，起始编号为5"
  echo "注意事项:  [启动节点数量] [起始节点编号] 参数可选，默认为1, 参数需为大于0的整数。"
  exit 0
fi

# Check if the number of nodes is provided as an argument
if [ $# -eq 0 ]; then
  echo "未提供启动节点数量和起始节点编号参数，默认启动一个节点，起始编号为1"
  echo "**** 本次计划启动 $NUM_NODES 个节点，起始编号为 $START_INDEX ****"
else
  if [[ $1 =~ ^[1-9][0-9]*$ ]]; then
    NUM_NODES=$1
    if [ $# -eq 2 ] && [[ $2 =~ ^[1-9][0-9]*$ ]]; then
      START_INDEX=$2
    fi
  else
    echo "Error: 传入参数错误。 [启动节点数量] [起始节点编号] 参数需为大于0的整数。"
    echo "执行命令: \`sh $0 -h\` 查看帮助信息"
    exit 1
  fi
  echo "**** 本次计划启动 $NUM_NODES 个节点，起始编号为 $START_INDEX ****"
fi


# Create directories for each instance
NODES=""
echo ""
echo "** 开始创建节点环境 **"
for i in $(seq $START_INDEX $(($START_INDEX + $NUM_NODES - 1))); do
  mkdir node$i
  cp .env node$i/
  NODES="$NODES ./node$i"
  echo " node$i 节点环境创建完成！"
  cd node$i && sh ../scripts/run_nockchain_miner.sh > node$i.log 2>&1 &
  echo " node$i 节点启动完成！"
done

echo ""
echo "** 所有节点启动完成 **"
echo "本次启动的节点环境目录为：$NODES"