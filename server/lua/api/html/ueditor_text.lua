--[[
	banner的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"


local address="/html/ueditor_text.html"



	local model={dataSource}

	template.render(address,model)