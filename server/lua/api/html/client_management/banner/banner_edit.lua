--[[
	banner的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()

local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local db = require "db.base_db"
local bannerDbOp = db.new()


local temp={}
if args.id_pk and args.id_pk~="" then 
temp.id_pk=args.id_pk
end


local dbres,err = bannerDbOp.getBaseFromSql("select * from t_banner",temp,"and")

if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.print(cjson.encode(result))	
		return 
end

-- session必须开启缓存才能够使用，为了便捷开发，先不判断，而是直接跳转到index页面

-- if args.token == session.data.token then 
-- 	-- 从登陆跳过来，带了token才能跳转到html/index.html界面
-- 	local address="/html/index.html"
-- 	local model={}
-- 	template.render(address,model)
-- else
-- 	result = responeData.new_failed({},err)
-- end
local address="/html/client_management/banner/banner_edit.html"

local banner_edit_data
banner_edit_data=dbres
	local model={banner_edit_data=banner_edit_data}

	template.render(address,model)