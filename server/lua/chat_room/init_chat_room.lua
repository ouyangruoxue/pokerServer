--[[
-- chatroom/init_chatroom.lua
-- 聊天室模块创建，用来存储系统用户的聊天室信号量等信息
-- 支持多对多频道 
-- 支持 websocket
--
-- Author: Steven.com <zhangliutong@zhengsutec.com> 
-- 2017.03.12
--]]

local _Chatroom = require "chat_room.chat_room"	
local _Anchor = require "chat_room.anchor"
-- 读取数据库,生成聊天室数据结构
local _M = {
	anchor_map = {};
	chat_room_map = {};
};
-- 创建主播
--[[
-- 将读取数据库进行 主播和主播房间的映射初始化 
 
--]]
_M.init_rooms = function(_self)
	-- 读取数据库,返回房间列表
	-- 如果主播没有上线,房间状态设置为false
	-- 初始化主播对应的房间
	local base_db = require "db.base_db"
	local basedb = base_db.new();
	local res ,err = basedb.getBaseFromSql("SELECT a.*,b.id_pk AS room_id_pk,b.game_type,b.limit_money,b.password,b.limit_players,c.roomid as neteaseChatRoomId FROM t_anchor  a LEFT JOIN t_anchor_room b ON b.anchor_id_fk = a.id_pk LEFT JOIN t_netease_chat_room c ON c.anchor_user_code = a.user_code_fk",{},"and")
	 reslength = table.getn(res)
			--判断是否查询到结果
	 if reslength > 0 then
   				
	 		for k,v in pairs(res) do
	 			local anchordetail = v
	 			local anchorId = anchordetail.user_code_fk
	 			local anchor = _Anchor:new(anchorId,anchordetail.anchor_title,anchordetail.anchor_description,anchor_logo,anchordetail.neteaseChatRoomId);

	 			local roomId = anchordetail.room_id_pk;
				local chat_room = _Chatroom:new(roomId,nil,anchorId,anchordetail.limit_players,anchordetail.game_type,anchordetail.neteaseChatRoomId,anchordetail.password);
				chat_room.prepare(false,chat_room)
				if anchorId and roomId then
					anchor.chatRooms[roomId] = chat_room; 
					_self.anchor_map[anchorId] = anchor;
					_self.chat_room_map[roomId] = chat_room; 
				end
	 		end

	 end
	  
end


--[[
--  getAnchor 返回主播对象
-- example
    local AnchorMap = require "chat_room.init_chat_room"
    local anchorId = "anchorId"
    local anchor = AnchorMap:getAnchor(anchorId)
    if not anchor then
    	--print(error)
	end

-- @param _self --
-- @param anchorId 主播id
-- @return 返回主播对象,如果主播不存在 返回nil 
--]]
_M.getAnchor = function(_self,anchorId)
	return _self.anchor_map[anchorId];
end 



--[[
--  getChatRoom 返回聊天室 对象
-- example
    local ChatRoomMap = require "chat_room.init_chat_room"
    local roomId = "roomId"
    local chatRoom = ChatRoomMap:getAnchor(roomId)
    if not chatRoom then
    	--print(error)
	end

-- @param _self --
-- @param roomId  房间id
-- @return 返回主播对象,如果主播不存在 返回nil 
--]]
_M.getChatRoom = function(_self,roomId)
	return _self.chat_room_map[roomId];
end 
 


return _M