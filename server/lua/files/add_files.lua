
--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:add_files.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  用户或者后台管理人员上传图片记录接口,
--	本接口支持单文件多文件上传文件夹上传的方式,当用户未携带文件夹信息则存储在顶层文件夹中
--]]

local cjson     = require "cjson"
local file_apis = require "files.common.file_apis"
local zsrequest = require "common.request"
local api_data  = require "common.api_data_help"


local args = zsrequest.getArgs();
-- 获取用户的编号
local user_code =args["user_code"];
if not user_code then
-- 没有传递用户编号,直接无法为用户提供api
	return ngx.say(cjson.encode(api_data.new_failed()));
end

--[[
-- 读取用户需要上传的文件信息,格式为json;用户上传的文件数据为空或者不认识,则数据错误
-- 用户将通过控件或者http单文件上传都将通过本文件定义方式 将用户信息存入系统,
-- 用户可按照以下方式进行数据封装上传,首先系统将本地的文件上传进行遍历判断哪些文件服务器上已经存在,存在的则无需上传
-- 不存在的按照顺序进行上传,未来支持多个文件上传(上限为5个),上传成功之后将状态反馈给客户端
--	具体步骤如下;
	1,具体用户将需要上传的文件信息通过以下进行封装,系统获取该文件信息之后解析为lua数据表
	2,遍历lua表,首先将所有的foder信息创建完毕,在遍历文件是否存在，已经存在的文件则直接移除到已经完成状态;
		如果不存在文件系统将写入文件,生成文件记录
	3,系统将实施将状态上传状态定时返回到客户端
-- 用户上传的文件格式(本地使用lua的表来展示,即lua表格式,容易阅读)
{
--	user_code="user_code_01",
--	parent_folder="我的头像",
--	files_info={
				{file_name="2017.02.27",type="folder"},
				{file_name="file01.jpg",folder_name="2017.02.27",file_code="file_code_01",sha1_code="sha1_code_01",md5_code="md5_code_01"},
				{file_name="file02.jpg",folder_name="2017.02.27",file_code="file_code_02",sha1_code="sha1_code_02",md5_code="md5_code_02"},
				}
--}

]]
local files_info = args["files_info"];