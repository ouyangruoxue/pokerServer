--[[
	获取礼品类型列表
	@param id_pk
	@param gift_name
	@param is_join_share 是否参与主播分红结算
	
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

if args.gift_name and args.gift_name~="" then 
user.gift_name=args.gift_name
end

if args.is_join_share and args.is_join_share~="" then 
user.is_join_share=args.is_join_share
end

	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_gift_type",user,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return err
	end



local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))

