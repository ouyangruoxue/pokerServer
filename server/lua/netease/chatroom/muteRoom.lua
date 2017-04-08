--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:muteRoom.lua
--  功能:将聊天室整体禁言
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  设置聊天室整体禁言状态（仅创建者和管理员能发言）
--]]

-- 参数说明
-- 参数			类型	必须	说明
-- roomid		long	是		聊天室id
-- operator		String	是		操作者accid，必须是管理员或创建者
-- mute			String	是		true或false
-- needNotify	String	否		true或false，默认true
-- notifyExt	String	否		通知扩展字段



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local headr = neteaseHead.getNeteaseHttpHeadr(0)
local res, err = httpc:request_uri("https://api.netease.im/nimserver/chatroom/muteRoom.action",{
        method = "POST",
        body = ngx.encode_args(args),
        ssl_verify = false, -- 需要关闭这项才能发起https请求
        headers = headr,
      })
if not res then
	ngx.say(cjson.encode(err))
	return
end

ngx.status = res.status
--code
--200成功
--414 其它错误（具体看待，可能是注册重复等）
--403 非法操作
--416 频率控制
--431 http重复请求
--500 服务器内部错误
-- 聊天室相关错误码	
-- 13001	IM主连接状态异常
-- 13002	聊天室状态异常
-- 13003	账号在黑名单中,不允许进入聊天室
-- 13004	在禁言列表中,不允许发言
--"Content-Type": "application/json; charset=utf-8"
-- {
--   "desc": {
--     "success": true
--   },
--   "code": 200
-- }
ngx.say(res.body)