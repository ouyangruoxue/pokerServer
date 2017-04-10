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
if args.game_id and args.game_id~="" then 
	user.id_pk=args.game_id
	else
		return "奖金池id为空"
end

local temp={}
-- 查询游戏类型
temp.id_pk=user.id_pk
local dbres1,err1 = userDbOp.getBaseFromSql("SELECT * FROM t_game_type ",temp,"and")
if not dbres1 or type(dbres1) ~= "table" then 
		local  result = responeData.new_failed({},err1)
		ngx.print(cjson.encode(result))	
		return 
end

-- 通过游戏id从redis中查找对应的游戏类型
local redis = require "redis.zs_redis"
local red = redis:new()

--[[

此处写死，1表示德州扑克，2表示牛牛，数据库中也要是这样的对应关系，否则redis的奖金池不是数据库对应游戏的奖金池

]]
local bonus_pool,err
if "1"==user.id_pk then 
	 bonus_pool,err =red:get("wj_dzpk_capital_pool")
		if not bonus_pool then 
			ngx.log(ngx.ERR,"err1:"..err)
			return "奖金池为空"
		end

else
	bonus_pool,err =red:get("wj_niuniu_capital_pool")
		if not bonus_pool then 
			ngx.log(ngx.ERR,"err2:"..err)
			return "奖金池为空"
		end
end

local address="/html/client_management/bonus_pool/bonus_pool_opt.html"


local game_type_name
game_type_name=dbres1

	local model={bonus_pool=bonus_pool,game_type_name=game_type_name}

	template.render(address,model)