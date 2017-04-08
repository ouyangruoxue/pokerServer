--[[
	新增/修改 用户账户信息 数据，如果有id，就是修改，没有id就是新增
	@param id
	@param user_code_fk
	@param balance 用户当前余额，包含不可移动的部分。用户查余额的时候，不可移动的显示在边上。',
	@param nomove_balance 账户余额，不可消费的部分
	@param integral 用户积分
	@param popularity 人气
	@param reputation  信誉指数
	@param pay_password 二级支付密码
]]-- 


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis" 
local responeData = require"common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

if not args.user_code  then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end

local temp = {}
temp.user_code_fk = args.user_code

--获取用户钱包余额
local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select balance,nomove_balance,integral from t_account",temp,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))	
		return 
	end
local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))




