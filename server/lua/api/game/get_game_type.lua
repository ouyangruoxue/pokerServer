--[[
	获取游戏类型列表
	@param id_pk
	@param game_name
	@param parent_game 上一级游戏
	
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

if args.game_name and args.game_name~="" then 
user.game_name=args.game_name
end

if args.parent_game and args.parent_game~="" then 
user.parent_game=args.parent_game
end


	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb:new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_game_type",user,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return 
	end



local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))