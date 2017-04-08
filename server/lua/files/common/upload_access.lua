--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:upload_access.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  文件接入接口的api检测 系统需要在url中检查唯一系统编号信息,如果没有认证信息则拒绝提供后续访问呢功能
--]]
local api_data = require "common.api_data_help"
local cjson		= require "cjson"

local args = ngx.req.get_uri_args()


-- 判断平台是否授权的用户
local usercode = args["usercode"];
local token = args["token"];
local timestamp = args["timestamp"];



------------ 用户权限判断
if not usercode or not token or not timestamp then 
	 	data = api_data.new(ZS_ERROR_CODE.RE_ACCEESS_ERR);
	 	 -- 产生一个错误的结果,然后系统将返回----------------- 
	 	ngx.say(cjson.encode(data))
		ngx.eof()
	 	--ngx.exit(ngx.HTTP_SPECIAL_RESPONSE)
else 
	 	 
end
-- 业务判断如果是opt==pre 作为图片预先处理的通信握手
local opt = args["opt"];
if opt == "pre" then

end
local tokenex = args["tokenex"]; 
-- 判断一次是否携带了token状态 如果不是pre状态的时候 
if not tokenex then 
	ngx.say(cjson.encode(api_data.new_failed())); 
	ngx.eof();
end
-- 访问该接口的平台,api格式 ,网页 两类
--[[
local apf = args["apf"]
if not apf then apf = "api" end;
]]

--[[
if apf == "api" then
	-- api 返回系统 json数据格式
	local data ;
	if not usercode or not usertoken or timestamp then 
	 	data = api_data.new(ZS_ERROR_CODE.RE_ACCEESS_ERR);
	 	 -- 产生一个错误的结果,然后系统将返回
	 	ngx.say("result :"..cjson.encode(data))
		ngx.eof()
	 	--ngx.exit(ngx.HTTP_SPECIAL_RESPONSE)
	end

else
	-- 其他则为网页模式 系统将进行重定向调用
	ngx.say("result "..cjson.encode(args))
	ngx.exit(ngx.HTTP_SPECIAL_RESPONSE)
end
 ]]