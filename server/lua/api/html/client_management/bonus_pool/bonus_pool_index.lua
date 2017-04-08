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

local temp = {}
local user={}


local dbres,err = userDbOp.getBaseFromSql("SELECT t1.opt_money,t3.game_name,t1.update_time FROM t_bonus_pool_history t1 LEFT JOIN t_bonus_pool t2 ON t1.pool_id_fk = t2.id_pk LEFT JOIN t_game_type t3 ON t2.game_id_fk = t3.id_pk",user,"and")
local dbres1,err1 = userDbOp.getBaseFromSql("SELECT count(*) as all_clum  FROM t_bonus_pool_history t1 LEFT JOIN t_bonus_pool t2 ON t1.pool_id_fk = t2.id_pk LEFT JOIN t_game_type t3 ON t2.game_id_fk = t3.id_pk",user,"and")
if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.print(cjson.encode(result))	
		return 
end

if not dbres1  then 
		local  result = responeData.new_failed({},err1)
		ngx.print(cjson.encode(result))	
		return 
end

local res,errs = userDbOp.getBaseFromSql("SELECT * FROM t_game_type",temp,"and")

if not res or type(res) ~= "table" then 
		local  result = responeData.new_failed({},errs)
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
local address="/html/client_management/bonus_pool/bonus_pool_index.html"
local bonus_pool_index_data
local bonus_pool_index_ac
local game_type_data
bonus_pool_index_data=dbres
bonus_pool_index_ac=dbres1
game_type_data=res
	local model={bonus_pool_index_data=bonus_pool_index_data,game_type_data=game_type_data,bonus_pool_index_ac=bonus_pool_index_ac}

	template.render(address,model)