-- 图片上传接口，需要接收服务器的ip和端口号
-- 调用后图片保存在html中的uploadfile文件夹中(与assert同级),返回一个完整的地址

local cjson =require"cjson"
local files_api = require "files.common.file_apis"

local ip="172.16.10.20"
local port="80"

	local path = files_api.handle_uploading()
	local completely_path = "http://"..ip..":"..port.."/uploadfile/"..path

local path11={completely_path=completely_path}
    ngx.print(cjson.encode(path11))
