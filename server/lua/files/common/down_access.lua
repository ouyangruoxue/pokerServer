--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:down_access.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  文件下载入口检测 根据不同用户权限动态修改下载速度
--]]


local api_data = require "common.api_data_help"
local cjson		= require "cjson"

local args = ngx.req.get_uri_args()



-- 根据当前的url 和 用户权限 动态设置 具体根据业务需要进行判断 是否需要权限下载要求
local url = ngx.req.get_uri;


-- 判断平台是否授权的用户
local usercode = args["usercode"];
local token = args["token"];
local timestamp = args["timestamp"];

