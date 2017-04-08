--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:file_redirect.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  文件模块 重定向的处理函数
--]]
local rd_help = require "common.redirect_help"
local cjson  = require "cjson"

local args = ngx.req.get_uri_args()

ngx.say("args :" .. cjson.encode(args))
return ngx.redirect("/index.html") 