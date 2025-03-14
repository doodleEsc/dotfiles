#!/bin/bash

# 检查 cfssl 是否已安装
if ! command -v cfssl &>/dev/null || ! command -v cfssljson &>/dev/null; then
	echo "错误: cfssl 和 cfssljson 未安装"
	echo "Ubuntu/Debian 安装方法:"
	echo "  sudo apt-get update && sudo apt-get install -y golang-cfssl"
	echo "CentOS/RHEL 安装方法:"
	echo "  sudo yum install -y golang-cfssl"
	echo "手动安装方法:"
	echo "  go get -u github.com/cloudflare/cfssl/cmd/..."
	exit 1
fi

# 默认值
CN=""
HOSTS=""
O="My Organization"
OU="My Unit"
C="CN"
ST="Beijing"
L="Beijing"

# 显示主菜单
function show_main_menu() {
	clear
	echo "=== 证书生成工具 ==="
	echo "1. 初始化 CA 证书"
	echo "2. 生成服务器证书"
	echo "3. 生成客户端证书"
	echo "4. 查看帮助信息"
	echo "0. 退出"
	echo "===================="
	echo -n "请选择操作 [0-4]: "
}

# 显示帮助信息
function show_help() {
	clear
	echo "=== 帮助信息 ==="
	echo "本工具用于生成 SSL/TLS 证书，包括："
	echo "- CA 证书：作为根证书，用于签发其他证书"
	echo "- 服务器证书：用于服务器身份验证"
	echo "- 客户端证书：用于客户端身份验证"
	echo
	echo "证书字段说明："
	echo "- CN (Common Name): 通用名称，如域名或服务名"
	echo "- O  (Organization): 组织名称"
	echo "- OU (Organizational Unit): 组织单位"
	echo "- C  (Country): 国家代码（如：CN）"
	echo "- ST (State): 州/省"
	echo "- L  (Locality): 城市"
	echo
	echo "使用流程："
	echo "1. 首先初始化 CA 证书"
	echo "2. 使用 CA 证书签发服务器或客户端证书"
	echo
	echo "按回车键返回主菜单..."
	read
}

# 获取证书基本信息
function get_cert_info() {
	echo -n "请输入通用名称 (CN) [默认: $CN]: "
	read input
	CN=${input:-$CN}

	echo -n "请输入组织名称 (O) [默认: $O]: "
	read input
	O=${input:-$O}

	echo -n "请输入组织单位 (OU) [默认: $OU]: "
	read input
	OU=${input:-$OU}

	echo -n "请输入国家代码 (C) [默认: $C]: "
	read input
	C=${input:-$C}

	echo -n "请输入州/省 (ST) [默认: $ST]: "
	read input
	ST=${input:-$ST}

	echo -n "请输入城市 (L) [默认: $L]: "
	read input
	L=${input:-$L}
}

# CA 配置 JSON
CA_CONFIG_JSON='{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "expiry": "876000h"
      },
      "server": {
        "expiry": "876000h",
        "usages": [
          "signing",
          "key encipherment",
          "server auth"
        ]
      },
      "client": {
        "expiry": "876000h",
        "usages": [
          "signing",
          "key encipherment",
          "client auth"
        ]
      },
      "peer": {
        "expiry": "876000h",
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ]
      }
    }
  }
}'

# CA CSR JSON 模板
CA_CSR_JSON_TEMPLATE='{
  "CN": "%s",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "C": "%s",
      "ST": "%s",
      "L": "%s",
      "O": "%s",
      "OU": "%s"
    }
  ],
  "CA": {
    "expiry": "876000h"
  }
}'

# CSR JSON 模板
CSR_JSON_TEMPLATE='{
  "CN": "%s",
  "hosts": [%s],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "C": "%s",
      "ST": "%s",
      "L": "%s",
      "O": "%s",
      "OU": "%s"
    }
  ]
}'

# 初始化 CA 证书
function init_ca() {
	CA_CSR_JSON=$(printf "$CA_CSR_JSON_TEMPLATE" "$CN" "$C" "$ST" "$L" "$O" "$OU")
	echo "$CA_CSR_JSON" | cfssl gencert -initca - | cfssljson -bare ca
	echo "CA 证书生成完毕："
	echo "- CA 证书: ca.pem"
	echo "- CA 密钥: ca-key.pem"

	#generate_install_scripts
}

# 检查 CA 证书文件是否存在
function check_ca_files() {
	if [[ ! -f "ca.pem" ]] || [[ ! -f "ca-key.pem" ]]; then
		echo "错误: CA 证书文件不存在"
		echo "请先执行选项 1 '初始化 CA 证书'"
		echo "按回车键返回主菜单..."
		read
		return 1
	fi
	return 0
}

# 生成服务器证书
function gen_server_cert() {
	if [[ -z "$HOSTS" ]]; then
		echo "错误: 必须指定主机名 (Hosts)。"
		usage
	fi
	HOSTS_JSON=$(echo "$HOSTS" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')
	SERVER_CSR_JSON=$(printf "$CSR_JSON_TEMPLATE" "$CN" "$HOSTS_JSON" "$C" "$ST" "$L" "$O" "$OU")

	echo "$SERVER_CSR_JSON" | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=<(echo "$CA_CONFIG_JSON") -profile=server - | cfssljson -bare server
	echo "服务器证书生成完毕："
	echo "- 服务器证书: server.pem"
	echo "- 服务器密钥: server-key.pem"
}

# 生成客户端证书
function gen_client_cert() {
	CLIENT_CSR_JSON=$(printf "$CSR_JSON_TEMPLATE" "$CN" "" "$C" "$ST" "$L" "$O" "$OU")

	echo "$CLIENT_CSR_JSON" | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=<(echo "$CA_CONFIG_JSON") -profile=client - | cfssljson -bare client
	echo "客户端证书生成完毕："
	echo "- 客户端证书: client.pem"
	echo "- 客户端密钥: client-key.pem"
}

# 初始化 CA 证书
function init_ca_interactive() {
	clear
	echo "=== 初始化 CA 证书 ==="
	get_cert_info

	echo -n "确认生成 CA 证书？(y/n): "
	read confirm
	if [[ $confirm == [Yy] ]]; then
		init_ca
		echo "按回车键返回主菜单..."
		read
	fi
}

# 生成服务器证书
function gen_server_cert_interactive() {
	clear
	echo "=== 生成服务器证书 ==="

	# 检查 CA 证书文件
	check_ca_files || return

	get_cert_info

	echo -n "请输入主机名列表 (用逗号分隔，如：localhost,example.com,192.168.1.1): "
	read HOSTS

	echo -n "确认生成服务器证书？(y/n): "
	read confirm
	if [[ $confirm == [Yy] ]]; then
		gen_server_cert
		echo "按回车键返回主菜单..."
		read
	fi
}

# 生成客户端证书
function gen_client_cert_interactive() {
	clear
	echo "=== 生成客户端证书 ==="

	# 检查 CA 证书文件
	check_ca_files || return

	get_cert_info

	echo -n "确认生成客户端证书？(y/n): "
	read confirm
	if [[ $confirm == [Yy] ]]; then
		gen_client_cert
		echo "按回车键返回主菜单..."
		read
	fi
}

# 主循环
while true; do
	show_main_menu
	read choice
	case $choice in
	1) init_ca_interactive ;;
	2) gen_server_cert_interactive ;;
	3) gen_client_cert_interactive ;;
	4) show_help ;;
	0) exit 0 ;;
	*) echo "无效选择，请重试" ;;
	esac
done
