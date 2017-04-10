local files_api = require "files.common.file_apis"
local cjson     = require "cjson"
local api_data	= require "common.api_data_help"
local request	= require "common.request"
local uuid 		= require "resty.uuid"
local resty_sha1 = require "resty.sha1"
local resty_md5 = require "resty.md5"

local str       = require "resty.string"
-- local inRes , errorcode = files_api.insert_new_file(file_code,file_md5,file_sha1);
-- ngx.say(inRes)
-- local res ,errorcode = files_api.find_file_by_sha1(file_sha1);
-- if res then
--     ngx.say(cjson.encode(res))
-- end
--[[
ngx.say(file_code)
local res ,errorcode = _M.insert_new_file(file_code,file_md5,file_sha1);
if not res then
    if(errorcode == 1062) then
        return 0;
    end
    return err,errorcode;
end
]]
 
local args = ngx.req.get_uri_args()
-- 查询当前的请求

-- usercode 表示用户编号,该文件会作为用户上传的文件存储在用户空间中
local usercode = args["usercode"]; 

-- 1, 获取为预先查询还是上传阶段
-- 操作类型 opt=pre表示预上传,系统将会返回一段加密code给客户端  客户端再下次上传时需要带上该code作为唯一性认证
local opt = args["opt"];
if opt == "pre" then 
	local res = files_api.pre_uploading(usercode);
	ngx.log(ngx.ERR,"预判断  返回结果为-----------"..cjson.encode(res))
    ngx.say(cjson.encode(res)); 
else 
	-- tokenex 未来作为用户预上传时的提供的一次性使用券,由系统产生 
	local res = files_api.handle_uploading();
	ngx.log(ngx.ERR,"上传完成  返回结果为-----------"..cjson.encode(res))
    ngx.say(cjson.encode(res)); 
end

local testdata ;






