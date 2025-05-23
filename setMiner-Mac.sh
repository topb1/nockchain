#!/bin/bash
## 作者: 0x13904b 
#### 有问题请联系:
# Twitter|X: https://x.com/0x13904b
# Telegram:  https://t.me/twitter_0x13904b


if [ "$1" = "-h" -o "$1" = "--help" ]; then
  echo ""
  echo "此脚本提供了 Mac 系统下的依赖包检测安装，以及 Nockchain 项目的编译和启动。适配官方库62d6494版本教程"
  echo "使用方法:  sh $0 "
  echo "注意事项: "
  echo " 1. 启动前请手动删除已clone的 nockchain 文件夹，避免冲突。命令：rm -rf nockchain"
  echo " 2. 脚本会自动新生成钱包并备份在./nockchain/keys.export，公钥会自动导入.env文件。"
  echo "  2.1 nockchain-wallet show-master-pubkey   #可以查看当前钱包公钥。"
  echo "  2.2 nockchain-wallet show-seedphrase      #可以查看当前钱包助记词。"
  echo "  2.1 nockchain-wallet show-master-privkey  #可以查看当前钱包主私钥。"
  echo " 3. nockchain安装进度请查看 tail -f ./nockchain/log.txt"
  exit 0
fi

##############################  新机器依赖包安装 代码 ###################################
#  Mac 系统下检测并安装 Homebrew
if ! command -v brew &> /dev/null; then
    echo "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew 已安装：$(brew --version)"
fi

#  Mac 系统下检测并安装 Xcode 命令行工具
if ! command -v git &> /dev/null; then
    echo "安装 Xcode 命令行工具..."
    xcode-select --install
else
    echo "Xcode 命令行工具已安装"
fi

#  Mac 系统下检测并安装 Make
if ! command -v make &> /dev/null; then
    echo "安装 Make..."
    xcode-select --install
else
    echo "Make 已安装"
fi

#  Mac 系统下检测 Curl
if ! command -v curl &> /dev/null; then
    echo "安装 Curl..."
    brew install curl
else
    echo "Curl 已安装：$(curl --version | head -n 1)"
fi

#  Mac 系统下检测并安装 Rust
if ! command -v rustc &> /dev/null; then
    echo "安装 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    echo "Rust 已安装"
fi

# # 安装 Docker
# # if ! command -v docker &> /dev/null; then
# #     echo "安装 Docker..."
# #     brew install --cask docker
# #     echo "请手动启动 Docker Desktop 并完成设置。"
# # fi

# 克隆 Nockchain 仓库
if [ ! -d "nockchain" ]; then
    git clone https://github.com/zorp-corp/nockchain
fi
cd nockchain
cp .env_example .env




##############################  编译以及启动挖矿的代码 ###################################

#步骤 1： 安装 Hoonc（Jock/Hoon 编译器）
### 对应官方文档命令：make install-hoonc ###
echo '1. make install-hoonc 开始' > ./log.txt
make install-hoonc
export PATH="$HOME/.cargo/bin:$PATH"
echo '  ****** make install-hoonc 完成 ******' >> ./log.txt

#步骤 2： 构建 Nockchain
### 对应官方文档命令：make build ###
echo '2. make build 开始' >> ./log.txt
make build
echo '  ****** make build 完成 ******' >> ./log.txt

#步骤 3： 构建钱包(install-nockchain-wallet) 
### 对应官方文档命令：make install-nockchain-wallet ###
echo '3. make install-nockchain-wallet 开始' >> ./log.txt
make install-nockchain-wallet
echo '  ****** make install-nockchain-wallet 完成 ******' >> ./log.txt

#步骤 4： 安装nockchain(install-nockchain) 
### 对应官方文档命令：make install-nockchain ###
echo '4. make install-nockchain 开始' >> ./log.txt
make install-nockchain
echo '  ****** make install-nockchain 完成 ******' >> ./log.txt


# 生成钱包&导出keys
# if [ -z "$PUB_KEY" ]; then
    echo '\n-------------------------------------' >> ./log.txt
    echo '  ****** 生成钱包 & 导出keys ******' >> ./log.txt
    nockchain-wallet keygen >> ./keygen.txt 2>&1
    nockchain-wallet export-keys
    # 获取最新的公钥，替换默认的公钥
    PUB_KEY=$(grep -aoE "[23]{1}[a-zA-Z0-9]{127}" ./keygen.txt)
    sed -i -e "s/^export MINING_PUBKEY ?=.*$/export MINING_PUBKEY ?= ${PUB_KEY}/g" Makefile
    sed -i -e "s/^MINING_PUBKEY=.*$/MINING_PUBKEY=${PUB_KEY}/g" .env
    echo "公钥替换完成,当前公钥为:$PUB_KEY"
    echo '-------------------------------------\n' >> ./log.txt
# fi

#步骤 5： 启动 nockchain 挖矿
### 对应官方文档命令：sh ./scripts/run_nockchain_miner.sh ###
echo '5. 启动 nockchain 挖矿开始' >> ./log.txt
sh ./scripts/run_nockchain_miner.sh > ./mining.log 2>&1 &
echo '5. 启动 nockchain 挖矿完成' >> ./log.txt
echo '  ****** 启动 nockchain 完成 挖矿进行中... ******' >> ./log.txt

echo "Nockchain 挖矿中...."
echo "用命令 tail -f ./mining.log 查看挖矿实时进度日志"

##############################################################################
