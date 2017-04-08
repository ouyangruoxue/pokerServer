--[[
	获取筹码列表
	@param id_pk
	@param chip_name 筹码名称
	@param chip_icon 筹码图标
	@param chip_value 筹码价值
	@param chip_level 筹码等级
	@param chip_explain 筹码说明

]]--


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if args.id_pk and args.id_pk~="" then 
user.id_pk=args.id_pk
end 

if  args.chip_name and args.chip_name ~= "" then 
user.chip_name=args.chip_name
end

if  args.chip_icon and args.chip_icon ~= "" then 
user.chip_icon=args.chip_icon
end


if  args.chip_value and args.chip_value ~= "" then 
user.chip_value=args.chip_value
end


if  args.chip_level and args.chip_level ~= "" then 
user.chip_level=args.chip_level
end

if  args.chip_explain and args.chip_explain ~= "" then 
user.chip_explain=args.chip_explain
end


	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_chip",user,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return err
	end


local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))
