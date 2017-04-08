local cjson = require "cjson"
local basedb = require "db.anchor.anchor_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis" 
local responeData = require"common.api_data_help"
local anchors = require "chat_room.anchors_chat_rooms"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

if not args.anchor_user_code or not args.anchor_status  or not args.room_id_pk  or not args.room_type or not args.game_type then

	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
		ngx.say(cjson.encode(result))
	return	
end 

if tonumber(args.game_type) > 2 then
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
		ngx.say(cjson.encode(result))
	return	
end	


local baseDbOp	= basedb.new()
--进行数据库操作 包含事务回滚
local dbres,err = baseDbOp.updateAnchorOnOff(args)
	if not dbres then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))
		ngx.log(ngx.ERR,"faild to update t_anchor")
		return 
end

--修改房间状态
local chat_room = anchors:getChatRoom(args.room_id_pk)
	if chat_room  then
			chat_room.anchor_status = args.anchor_status
			chat_room.room_status = args.anchor_status
			chat_room.room_type = args.room_type
			chat_room.game_type = args.game_type

			if args.password then
				chat_room.roomPwd = args.password
			end	

			--chat_room.prepare(false,chat_room)
	end
		
local  result = responeData.new_success({})
	ngx.say(cjson.encode(result))

