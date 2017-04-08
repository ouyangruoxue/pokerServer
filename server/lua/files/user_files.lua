
--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:user_files.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  本脚本主要为用户提供文件操作相关的接口,类似网盘功能
--]]
local cjson     = require "cjson"
local file_apis = require "files.common.file_apis"
local zsrequest = require "common.request_args"
local api_data  = require "common.api_data_help"


local args = zsrequest.getArgs();


--[[
	user_file api 自动根据用户的get信息返回其数据
	系统将get 获得的用户信息作为参数,该结构为
	userCode,fileName,startIndex,recordSize
	table {
	start_index=0,
	offset=20, 
	user_code = "",
    file_name = "",
    file_code = "",
    folder_code = "",
    file_status = 0,
	」
 
]]
-- 读取用户系统编号
local user_code_fk = args["user_code"];
if not user_code_fk then
	-- 没有传递用户编号,直接无法为用户提供api
	return ngx.say(cjson.encode(DataTemp.new_failed()));
end
-- 读取用户需要查询的文件名
local param = {}
param.user_code_fk = user_code_fk
param.file_name = args["file_name"] 
-- 如果folder文件存在则调用文件夹接口进行文件列表和文件夹返回
param.folder_code = args["folder_code"]
--	读取用户的查询的分表的信息
local start_index = args["start_index"] and args["start_index"] or 0;
local offset = args["offset"] and args["offset"] or 20;

local srcSql = " select * from t_user_files "
local res,err = file_apis.find_user_files(srcSql,param,"and",start_index,offset);
local data ;

if not args then 
	data = api_data.new_failed();	
else
	data = api_data.new_success();	
	data.data = res;
end


ngx.say(cjson.encode(data))
