--[[
	获取房管列表
	@param anchor_id 主播id


	
]]--
local cjson = require "cjson"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"
local userDb = require "db.anchor.room_manager_db"
local jsonHelp =  require "common.jsonHelp"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
--必须带的参数
if not args.anchor_user_code  then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end
	local userDbOp = userDb.new()
	local dbres,err = userDbOp.getRoomManager(args.anchor_user_code)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"fail to query by database, err:",err)
		return err
	end

local tempTable={
	{'nickname','head_icon',idname='user_code_fk'}
}

local pfdbres = jsonHelp.cjsonPFTable2(dbres,tempTable)

local  result = responeData.new_success(dbres)
ngx.say(cjson.encode(result))

