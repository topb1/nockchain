#!/bin/bash
## 作者: 0x13904b 
#### 有问题请联系:
# Twitter|X: https://x.com/0x13904b
# Telegram:  https://t.me/twitter_0x13904b

if [ -z "$1" ]; then
    PUB_KEY=""
    echo "[INFO] 未设置公钥，默认会新生成钱包，将使用新公钥挖矿"
    if [ -z "$PUB_KEY" ]; then
        echo '\n-------------------------------------'
    fi
else
    PUB_KEY=$1
    if [[ $PUB_KEY =~ ^[23]{1}[0-9a-km-zA-HJ-NP-Z]{127}$ ]]; then
        echo "[INFO] 使用传入公钥挖矿，当前公钥是: $PUB_KEY"
    else
        echo "[ERROR] 公钥不符合要求，请检查！！！！"
        echo "[ERROR] 当前传入公钥是:$PUB_KEY"
        exit 1
    fi
fi

##############################  新机器依赖包安装 代码 ###################################
# # 检查并安装 Homebrew（macOS 的包管理器）
# if ! command -v brew &> /dev/null; then
#     echo "安装 Homebrew..."
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#     echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
#     eval "$(/opt/homebrew/bin/brew shellenv)"
# fi

# # 检查并安装 Git（如果未安装 CLT）
# if ! command -v git &> /dev/null; then
#     echo "安装 Xcode 命令行工具以获取 Git..."
#     xcode-select --install
# fi

# # 检查并安装 Make（通过 CLT）
# if ! command -v make &> /dev/null; then
#     echo "安装 Xcode 命令行工具以获取 Make..."
#     xcode-select --install
# fi

# # 检查 Curl（默认已存在）
# if ! command -v curl &> /dev/null; then
#     echo "安装 Curl..."
#     brew install curl
# else
#     echo "Curl 已安装：$(curl --version | head -n 1)"
# fi

# # 安装 Rust
# if ! command -v rustc &> /dev/null; then
#     echo "安装 Rust..."
#     curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#     source $HOME/.cargo/env
# fi

# # 安装 Docker
# # if ! command -v docker &> /dev/null; then
# #     echo "安装 Docker..."
# #     brew install --cask docker
# #     echo "请手动启动 Docker Desktop 并完成设置。"
# # fi

# # 克隆 Nockchain 仓库
# if [ ! -d "nockchain" ]; then
#     git clone https://github.com/zorp-corp/nockchain
# fi
# cd nockchain




##############################  编译以及启动挖矿的代码 ###################################

#步骤 1： 安装 Choo（Jock/Hoon 编译器）
### 对应官方文档命令：make install-hoonc ###
echo '1. make install-hoonc 开始' > ./log.txt
make install-hoonc
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
echo '  ****** make build 完成 ******' >> ./log.txt

#步骤 4： 安装nockchain(install-nockchain) 
### 对应官方文档命令：make install-nockchain ###
echo '4. make install-nockchain 开始' >> ./log.txt
make install-nockchain
echo '  ****** make build 完成 ******' >> ./log.txt


# 生成钱包&导出keys
if [ -z "$PUB_KEY" ]; then
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
fi

#步骤 5： 启动 nockchain 挖矿
### 对应官方文档命令：nockchain --mining-pubkey <your_pubkey> --mine ###
echo '5. 启动 nockchain 挖矿开始' >> ./log.txt
nockchain --mining-pubkey $PUB_KEY --mine > ./mining.log &2>&1 &
echo '5. run nockchain with mining_pubkey完成' >> ./log.txt
echo '  ****** 启动 nockchain 完成 挖矿进行中... ******' >> ./log.txt

echo "Nockchain 挖矿中...."
echo "用命令 tail -f ./mining.log 查看挖矿实时进度日志"

##############################################################################
