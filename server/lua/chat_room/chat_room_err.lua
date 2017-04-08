--[[
-- chatroom/chatroom_err.lua
-- 聊天室错误编号预定义
--
-- Author: Steven.com <zhangliutong@zhengsutec.com> 
-- 2017.03.12
--]]

local _M = {}

_M.ERR_OK = 0	--表示操作成功
_M.ERR_ANCHOR_OFFLINE = -1	-- 主播不在线
_M.ERR_CHATROOM_FULLED = -2  -- 聊天室人员已经满
_M.ERR_ANCHOR_ERROR = -3	-- 主播故障问题
_M.ERR_ANCHOR_CREATE_LOCK = -4  -- 创建主播聊天室的lock失败
_M.ERR_ROOM_PWD_ERROR = -5	-- 密码错误
_M.ERR_USER_CODE_ERROR = -6 --用户编号错误
_M.ERR_GAME_BET_TIME_OUT = -7 --下注时间已过
return _M

