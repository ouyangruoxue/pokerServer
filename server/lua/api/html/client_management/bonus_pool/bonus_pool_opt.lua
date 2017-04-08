--[[
	bonus_pool_index的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()

local db = require "db.base_db"
local userDbOp = db.new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local user={}
if args.game_id_fk and args.game_id_fk~="" then 
	user.game_id_fk=args.game_id_fk
end

-- 这是展示使用的数据 展示游戏类型下对应的奖金池金额
local dbres,err = userDbOp.getBaseFromSql("SELECT t2.*,t3.game_name FROM t_bonus_pool t2 LEFT JOIN t_game_type t3 ON t2.game_id_fk = t3.id_pk",user,"and")

if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.print(cjson.encode(result))	
		return 
end

local user1={}
local temp = {}
if args.id_pk and args.id_pk~="" and args.opt_money and args.opt_money~="" then -- 必须要接收奖金池id和操作的金额
	
temp.id_pk=args.id_pk

	if args.opt_money and args.opt_money~="" then 
	user1.opt_money=args.opt_money
	end
local dbres,err = userDbOp.updateBaseFromSql("t_bonus_pool",user1,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_anchor")
		return 
	end
	local  result = responeData.new_success({})
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
local address="/html/client_management/bonus_pool/bonus_pool_opt.html"
local bonus_pool_opt_data
bonus_pool_opt_data=dbres
	local model={bonus_pool_opt_data=bonus_pool_opt_data}

	template.render(address,model)