--[[
	获取奖金池
	@param id_pk  
	@param game_id_fk 游戏类型id
	@param money_count 奖金池现有金额
	@param update_time 更新时间
	
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

if args.game_id_fk and args.game_id_fk~="" then 
user.game_id_fk=args.game_id_fk
end 

	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_bonus_pool",user,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return 
	end

local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))
