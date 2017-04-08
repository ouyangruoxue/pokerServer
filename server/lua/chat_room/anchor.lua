--[[
-- chatroom/anchor.lua
-- 主播模块,包括主播的初始化定义和约束等,主播包含主播的id,用户信息,主播关联的房间信息
--
-- Author: Steven.com <zhangliutong@zhengsutec.com> 
-- 2017.03.12
--]]

local _CHATROOM_ERR = require "chat_room.chat_room_err"

local _M = {
	anchor_user_code = "",
	anchorName = "",
	anchorDes = "",
	anchorLogo = "", -- URL图片地址
	anchorEffect = "",
	anchorStatus = 1, -- 离线为0,在线为1,创建失败 2，
	anchorheat = 1, -- 热度
	anchorNeteaseRoomId = "",--云信聊天室id
	chatRooms = {},
};

_M.__index = _M;

--[[
-- getStatus 获得主播状态
-- 
-- example
   local anchor = {...} -- 默认主播已经创建初始化完成
   local status = anchor:getStatus(); -- 注意调用使用的是  :  调用
   -- 抑或 local status = anchor.getStatus(anchor); 

-- @param _self
-- @return 主播状态
]]
_M.getStatus = function ( _self )
	-- body
	return _self.anchorStatus;
end


--[[
-- joinRoom 加入房间的函数,携带用户id,用户的信号量,系统判断该用户id是否存在,
-- 如果存在则关闭之前的对象,由于系统中主播会携带多个聊天室,所以主播根据游戏房间进行分配,分配规则主要为
-- 房间的人数为50以下,则加入，如果都超过了50,则进行随机分配进房间
-- example
   -- 默认主播已经在请求中获得
    local anchor = {...} -- 默认主播已经创建初始化完成
	local roomId = anchor:join(userId,userSemp,pwd);


-- @param _self 对象本身,使用:则隐式调用
-- @param userId 玩家id
-- @param semp 玩家信号量
-- @param pwd  密码
-- @param 返回房间对象
]]
_M.joinRoom = function ( _self, userId, semp,roomPwd)
	-- body
	if _self.anchorStatus ~= 1 then
		return nil,_CHATROOM_ERR.ERR_ANCHOR_ERROR
	end
	-- 动态分布未处理 --------------------------------------------实际项目过程中需要处理
	local room = nil;
	for k,v in pairs(_self.chatRooms) do
		room = v;
	 	if not room then 
			ngx.log(ngx.ERR," room is nil error "..k)
		end
	end
	-- 动态分布未处理 --------------------------------------------实际项目过程中需要处理
	 
	-- 聊天室 共享内存,用于lock 
	local lock = _self.lock;
	if not lock then  
		ngx.log(ngx.ERR,"join anchor room error ,the lock is nil")
		return nil
	end
	-- 访问主播锁
 	local elapsed, err = lock:lock(_self.anchor_user_code) 
 	if not elapsed then 
    	 ngx.log(ngx.ERR,"failed to acquire the lock", err)
    	 return nil
	end
	if not room then 
		ngx.log(ngx.ERR," room is nil error ")
	end
	-- 本初代码需要优化成描述的样子,主要用于业务测试
	local roomErr = room:join(userId,semp,pwd) 
	if roomErr ~= _CHATROOM_ERR.ERR_OK then
		ngx.log(ngx.ERR,"join room error ", roomErr)
        return nil
	end

	-- 释放主播锁
    local ok, err = lock:unlock()
    if not ok then
        ngx.log(ngx.ERR,"failed to unlock: ", err)
        return nil
	end
 	return room; 
end



--[[
-- new 创建对象,传入系统认证的主播id，主播名称，主播描述，主播logo，主播特效,
-- 如果存在则关闭之前的对象,由于系统中主播会携带多个聊天室,所以主播
-- example
	local anchor = require "chatroom.anchor" .new( anchorId,anchorName,anchorDes,anchorLogo,anchorEffect )

-- @param anchorId 主播id
-- @param anchorName 主播名称
-- @param anchorDes 主播描述
-- @param anchorLogo 主播logo
-- @param anchorEffect 主播特效字段
-- @return 主播对象
]]
function _M:new(anchor_user_code,anchorName,anchorDes,anchorLogo,anchorEffect,anchorNeteaseRoomId)
	-- body
	local anchor = setmetatable({}, _M);
	 anchor.anchor_user_code = anchor_user_code;
	 anchor.anchorName = anchorName;
	 anchor.anchorDes = anchorDes;
	 anchor.anchorLogo = anchorLogo;
	 anchor.anchorEffect = anchorEffect;
	 anchor.anchorNeteaseRoomId = anchorNeteaseRoomId;
	 local resty_lock = require "resty.lock"  
	 local lock, err =  resty_lock:new("my_locks");
	if not lock then
        ngx.log(ngx.ERR,"failed to create lock: ", err)
        return anchor,_CHATROOM_ERR.ERR_ANCHOR_CREATE_LOCK
    end
    anchor.lock = lock;
    anchor.chatRooms = {};
	 -- local resty_lock = require "resty.lock"
	 return anchor,_CHATROOM_ERR.ERR_OK
end

return _M
