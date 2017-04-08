--[[
	登录页面的渲染文件
]]
local template = require "resty.template"

local address="/html/login.html"
local model={}
template.render(address,model)