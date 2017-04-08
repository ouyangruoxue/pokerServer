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
local reqArgs = require "common.request_args"
local userDb = require "db.anchor.anchor_db"
local responeData = require "common.api_data_help"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()


	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getAnchorList()
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return err
	end


local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))
