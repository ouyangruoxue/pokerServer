--[[
	新增/保存游戏类型
	@param id_pk  有id的是更新，没有id的是新增

	@param game_name  游戏名称
	@param game_logo  游戏图标
	@param game_description  游戏描述
	@param game_help  游戏帮助
	@param parent_game  上一级游戏
	@param game_effects  游戏特效id


]]


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  args.game_name and args.game_name ~= "" then 
user.game_name=args.game_name
end
if  args.game_logo and args.game_logo ~= "" then 
user.game_logo=args.game_logo
end
if  args.game_description and args.game_description ~= ""  then 
user.game_description=args.game_description
end
if  args.game_help and args.game_help ~= ""  then 
user.game_help=args.game_help
end
if  args.parent_game and args.parent_game ~= ""  then 
user.parent_game=args.parent_game
end
if  args.game_effects and args.game_effects ~= ""  then 
user.game_effects=args.game_effects
end


local userDbOp	= userDb.new()

local temp={}
temp.id_pk=args.id_pk

if args.id_pk and args.id_pk ~= ""  then 
	local dbres,err = userDbOp.updateBaseFromSql("t_game_type",user,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_game_type")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

else
	local dbres,err = userDbOp.insertBaseToSql("t_game_type",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to add t_game_type")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

end
