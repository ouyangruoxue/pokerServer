--[[
--  作者:zuoxiaolin 
--  日期:2017-03-14
--  文件名:list.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  本文件主要用于扩展部分lua未实现的常用方法,扩展lua方法的用户请注意编写函数的说明
    以及使用方法
--]]
local cjson = require "cjson"
local db = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis" 
local responeData = require"common.api_data_help"
local anchors = require "chat_room.anchors_chat_rooms"
local jsonHelp =  require "common.jsonHelp"
-- 获取参数
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

--必须带的参数
if not args.page then	
	local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
	ngx.say(cjson.encode(result))
	return	
end

local parm = {}
--判断是否有游戏类型
if  args.game_type and args.game_type ~= "" then
	parm.game_type = args.game_type
end	

if  args.room_type and args.room_type ~= "" then
	parm.room_type = args.room_type
end	


parm.room_status=1
local startindex = (tonumber(args.page)-1)*20

local offset = (tonumber(args.page))*20



local baseDbOp = db.new()
local dbres,err = baseDbOp.getBaseFromSql("SELECT a.*,b.id_pk AS room_id_pk,b.limit_money,b.game_type,b.password,b.limit_players,c.roomid as neteaseChatRoomId FROM t_anchor  a LEFT JOIN t_anchor_room b ON b.anchor_id_fk = a.id_pk LEFT JOIN t_netease_chat_room c ON c.anchor_user_code = a.user_code_fk",parm,"and",startindex,offset)


local tempTable={
	{'anchor_push_ur','anchor_url','video_info','channel_business','anchor_status','game_type','password','user_code_fk','anchor_title','anchor_description','anchor_live_time','signing_time','cut_ratio','highest_count','room_id_pk','limit_money','limit_players','neteaseChatRoomId',idname='id_pk'},
}


if not dbres or type(dbres) ~= "table" then 
		local  result = responeData.new_failed({},err)
		ngx.say(cjson.encode(result))	
		return 
end

for i,v in ipairs(dbres) do
	local info = v
	if v.room_id_pk then
		local chat_room = anchors:getChatRoom(v.room_id_pk)
		if chat_room  and chat_room.playerS then
			v.playerS = chat_room.playerS
		else
			v.playerS = 0 
		end	
	end
end

local pfdbres = jsonHelp.cjsonPFTable2(dbres,tempTable)

local  result = responeData.new_success(pfdbres)
ngx.say(cjson.encode(result))
