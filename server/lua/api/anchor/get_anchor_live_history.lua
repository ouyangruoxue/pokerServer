--[[
	获取直播历史
	@param id_pk
	@param anchor_id 主播id
    @param anchor_live_begindate  直播开始时间
	@param anchor_live_enddate   直播结束时间

	
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

if  args.anchor_id and args.anchor_id ~= "" then 
user.anchor_id_fk=args.anchor_id
end

if  args.anchor_live_begindate and args.anchor_live_begindate ~= "" then 
user.anchor_live_begindate=args.anchor_live_begindate
end

if  args.anchor_live_enddate and args.anchor_live_enddate ~= "" then 
user.anchor_live_enddate=args.anchor_live_enddate
end

	-- 从数据库中查询
	ngx.log(ngx.INFO,"now query by database...")
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getBaseFromSql("select * from t_anchor_live_history",user,"and")
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return err
	end


local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))

