--[[
	chip_index的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()
local userDb = require "db.base_db"






local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local temp={}



	-- 从数据库中查询
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_chip",temp,"and")
	local dbres1,err1 = userDbOp.getBaseFromSql("select COUNT(*) as all_clum  from t_chip",temp,"and")

	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return 
	end

	if not dbres1 then 
		local  result = responeData.new_failed({},err1)
		ngx.log(ngx.ERR,"fail to query by database, err:",err1)
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
local address="/html/client_management/chip/chip_index.html"

local chip_index_data
local chip_index_ac
chip_index_data=dbres
chip_index_ac=dbres1
	local model={chip_index_data=chip_index_data,chip_index_ac=chip_index_ac}

	template.render(address,model)