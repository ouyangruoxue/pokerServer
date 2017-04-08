--[[
	新增/保存直播历史记录
	@param id_pk  有id的是更新，没有id的是新增

	@param anchor_id 主播id
	@param anchor_live_begindate  直播开始时间
	@param anchor_live_enddate   直播结束时间

]]


local cjson = require "cjson"
local userDb = require "db.base_db"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"

-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
local user ={}

if  args.anchor_id and args.anchor_id ~= "" then 
user.anchor_id_fk=args.anchor_id
end

if  args.anchor_live_begindate and args.anchor_live_begindate ~= "" then 
user.anchor_live_begindate=args.anchor_live_begindate
end

if  args.anchor_live_enddate and args.anchor_live_enddate ~= "" then 
user.anchor_live_enddate=args.anchor_live_enddate
end



local userDbOp	= userDb.new()

local temp={}
temp.id_pk=args.id_pk

if args.id_pk and args.id_pk ~= ""  then 
	local dbres,err = userDbOp.updateBaseFromSql("t_anchor_live_history",user,temp)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_anchor_live_history")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

else
	local dbres,err = userDbOp.insertBaseToSql("t_anchor_live_history",user)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to add t_anchor_live_history")
		return 
	end
	local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

end
