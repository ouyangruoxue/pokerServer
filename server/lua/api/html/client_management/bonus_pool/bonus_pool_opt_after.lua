--[[
	bonus_pool_opt_after的渲染文件
]]
local template = require "resty.template"
local reqArgs = require "common.request_args"
local responeData = require"common.api_data_help"
local cjson = require "cjson"
local session =require "resty.session".open()
local redis = require "redis.zs_redis"

local db = require "db.base_db"
local userDb = db.new()


-- 修改奖金池的金额
--存在的条件是假设奖金池一定不为空，奖金池的名字一定传过来了，调用这个函数时，修改的金额也一定传过来了
function bonus_pool_change(pool_name,changed_money)
	local opt_monry
	local red = redis:new()
	-- 开始观察这个奖金池
	local watch = red:watch(pool_name)
	if not watch then
		return "乐观锁出错"
	end


	-- 进行操作
	local pool_money,error=red:get(pool_name)
	-- 按理，修改后的奖金池一定比修改前的奖金池数值小，所以，用原来的奖金池减修改后的奖金池，所得值为正，如果修改后的奖金池比修改前的奖金池大，则用修改后的减修改前的，所得为负
	ngx.log(ngx.ERR,"tonumber(changed_money)"..changed_money)
	ngx.log(ngx.ERR,"tonumber(pool_money)"..pool_money)

	if tonumber(pool_money)>tonumber(changed_money) then 
		opt_monry=tonumber(pool_money)-tonumber(changed_money)
	else
		local temp=tonumber(changed_money)-tonumber(pool_money)
		opt_monry="-"..temp
	end


	-- 开启事务
	local multi = red:multi();
	if not multi then
		return "乐观锁出错"
	end

	-- 修改结果
	local ok, err = red:set(pool_name,changed_money)
	if not ok then
		return "set value error"
	end

	-- 释放锁
	local exec = red:exec()
	if not exec then
		return "乐观锁执行出错"
	end

	-- 返回修改的数值

	return opt_monry
end



local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local user={}
local pool_history={}
local arg_money

-- 传入的id_pk是指的game_id
if args.id_pk and args.id_pk~="" then 
	user.id_pk=args.id_pk
	else
		return 
end

if args.change_money and args.change_money~="" then 
	arg_money=args.change_money
	else
		return "没有传入修改金额"
end

if args.update_time and args.update_time~="" then 
	pool_history.update_time=args.update_time
end 

--[[

此处写死，1表示德州扑克，2表示牛牛，数据库中也要是这样的对应关系，否则redis的奖金池不是数据库对应游戏的奖金池
   此外，在修改的时候，奖金池的数据可能由于游戏产生了输赢而发生改变，所以在修改奖金池的时候，要使用watch锁住这个奖金池，等修改完了之后再释放
]]
local temp_func_result
if "1"==user.id_pk then 
	pool_history.opt_money=bonus_pool_change("wj_dzpk_capital_pool",arg_money)
else 
	pool_history.opt_money=bonus_pool_change("wj_niuniu_capital_pool",arg_money)
end


	-- 生成奖金池历史记录表
	local userDbOp = userDb:new()
	pool_history.game_type_id=user.id_pk
	local dbres1,err1 = userDbOp.insertBaseToSql("t_bonus_pool_history",pool_history)
	if not dbres1 then 
		local  result = responeData.new_failed({},err1)
		ngx.print(cjson.encode(result))	
		return 
	end


local  result = responeData.new_success({})
ngx.say(cjson.encode(result))
