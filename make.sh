# 将编译信息输出到日志文件
make 1>log/info.log 2>log/warn.log

# 检测 log/warn.log 文件是否为空, 如果为空说明没有错误信息, 后续不需要对其内容进行正则替换
file_path="log/warn.log"
file_contents=$(cat "$file_path" | tr -d '[:space:]')

if [ -z "$file_contents" ]; then
        echo "The file is empty or contains only whitespace."
else
        # 需要替换的字符串
        search_string="/usr/local/arm/bin/arm-buildroot-linux-gnueabihf_sdk-buildroot/bin/../lib/gcc/arm-buildroot-linux-gnueabihf/7.5.0/../../../../arm-buildroot-linux-gnueabihf/bin/"

        # 替换成的字符串
        replace_string="\n"

        # 使用sed命令对文件内容进行正则替换
        sed -i "s#$search_string#$replace_string#g" "$file_path"
fi
