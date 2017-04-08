--[[
	获取主播列表
	@param id_pk
	@param channel_business 渠道商
	@param anchor_status 主播状态
	@param user_code 上一级游戏
	@param parent_game 用户code
	@param anchor_title 直播标题
	@param anchor_description 直播描述
	@param anchor_live_time 直播时间
	@param signing_time 签约时间
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

if args.channel_business and args.channel_business~="" then 
user.channel_business=args.channel_business
end

if args.anchor_status and args.anchor_status~="" then 
user.anchor_status=args.anchor_status
end

if args.user_code and args.user_code~="" then 
user.user_code_fk=args.user_code
end

if args.anchor_title and args.anchor_title~="" then 
user.anchor_title=args.anchor_title
end


if args.anchor_description and args.anchor_description~="" then 
user.anchor_description=args.anchor_description
end

if args.anchor_live_time and args.anchor_live_time~="" then 
user.anchor_live_time=args.anchor_live_time
end

if args.signing_time and args.signing_time~="" then 
user.signing_time=args.signing_time
end



	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_anchor",user,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return err
	end



local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))
