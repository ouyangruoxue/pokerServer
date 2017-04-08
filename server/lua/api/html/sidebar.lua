--[[
	sidebar的渲染文件  将跳转链接放在这里，因为如果不放在这里的话，index页面跳转到其他页面了，index的lua文件中的各种链接对应的字段就为空了，无法跳转，但是因为所有的页面中都包含有sidebar.html
	所以将页面跳转的链接放在sidebar的lua文件中，这样每次点击链接，都能找到链接对应的地址字符串
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()

local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()



-- if args.token == session.data.token then 
-- 	-- 从登陆跳过来，带了token才能跳转到html/index.html界面
-- 	local address="/html/index.html"
-- 	local model={}
-- 	template.render(address,model)
-- else
-- 	result = responeData.new_failed({},err)
-- end
	local address="/html/part_html/sidebar.html"
	-- local model={index_address="http://localhost/api/html/index?token="..session.data.token}

	-- 这里也是一样的，先用没有token的
	local model={}
	template.render(address,model)