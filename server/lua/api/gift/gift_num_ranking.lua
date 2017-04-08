--[[
	获取送礼排行表 
	@parm anchorId
]]--
local cjson = require "cjson"
local reqArgs = require "common.request_args"
local userDb = require "db.base_db"
local responeData = require "common.api_data_help"
require "init.lua_func_ex"
local redis = require "redis.zs_redis"
local red = redis:new()

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()


if not args.anchor_user_code then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end

local function compare(x, y) --从大到小排序
    return x.gift_number > y.gift_number         --如果第一个参数大于第二个就返回true，否则返回false
end


local function getTableTenData(srctable)
	local temp = {}
	local index = 1
	for k,v in pairs(srctable) do
		temp[index] = v
		index = index +1
	end
	table.sort( temp, compare)
	return temp

end




local anchor_user_code = args["anchor_user_code"]
--存放信息如下
-- rec_user_code gift_type_id_fk  gift_number gift_logo gift_name  anchorId
--
local redisDayKey = string.format("giftrank_num_%s_day",anchor_user_code) 
local redisWeekKey = string.format("giftrank_num_%s_week",anchor_user_code)
local redisMonthKey = string.format("giftrank_num_%s_month",anchor_user_code) 

--获取日榜
local resday, errday = red:hgetall(redisDayKey)
ngx.log(ngx.ERR,"---------------------------1111111111111111111111",cjson.encode(resday))
--获取周榜 
local resweek, errweek = red:hgetall(redisWeekKey)
--获取月榜 
local resmonth, errmonth = red:hgetall(redisMonthKey)

local weektable = nil
local monthtable = nil
local daytable = nil
	--周榜
	if resweek then
		 weektable = table.array2rcordForJson(resweek)
	end	
	--月榜
	if resmonth then
		 monthtable = table.array2rcordForJson(resmonth)
	end 	
	--总榜
	if resday then
		daytable = table.array2rcordForJson(resday)
	end	

local result = {}
result.week = {}
result.month={}
result.day = {}



  if weektable then
  	result.week = getTableTenData(weektable)
  end	

  if monthtable then
  	result.month = getTableTenData(monthtable)
  end

  if daytable then
  	result.day = getTableTenData(daytable)
  end


local  respone = responeData.new_success(result)
ngx.say(cjson.encode(respone))

