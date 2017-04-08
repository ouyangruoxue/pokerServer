--[[
   新增/修改 用户账户信息 数据，如果有id，就是修改，没有id就是新增
	@param id
	@param user_code_fk
	@param balance 用户当前余额，包含不可移动的部分。用户查余额的时候，不可移动的显示在边上。',
	@param nomove_balance 账户余额，不可消费的部分
	@param integral 用户积分
]]--

local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis" 
local responeData = require"common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

--必须带的参数
if not args.user_code  then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end


local temp ={}
if args.id_pk and args.id_pk~="" then 
	temp.id_pk=args.id_pk
end 

if args.user_code and args.user_code~="" then 
	temp.user_code_fk=args.user_code
end 

if args.balance and args.balance~="" then 
	temp.balance=args.balance
end 

if args.nomove_balance and args.nomove_balance~="" then 
	temp.nomove_balance=args.nomove_balance
end 

if args.integral and args.integral~="" then 
	temp.integral=args.integral
end 



local userDbOp = userDb.new()
local dbres = nil;
local err = nil;
--插入
if not args["id_pk"]  then

 dbres,err = userDbOp.insertBaseToSql("t_account",temp)

if not dbres then 
		local  result = responeData.new_failed({},err)
	ngx.say(cjson.encode(result))
		return err
	end

else
--更新
local kParm = {}
kParm.user_code_fk = args["user_code"]
dbres,err = userDbOp.updateBaseFromSql("t_account",temp,kParm)

if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		return 
	end
end

local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))






