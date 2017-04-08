--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:get.lua
--  功能:查询聊天室信息
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  查询聊天室信息
--]]

-- 参数说明
-- 参数					类型	必须	说明
-- roomid				long	是		聊天室id
-- needOnlineUserCount	String	否		是否需要返回在线人数，true或false，默认false




local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/chatroom/get.action",{
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
--   "chatroom": {
--     "roomid": 66,
--     "valid": true,
--     "muted":false, //聊天室是否处于全体禁言状态，全体禁言时仅管理员和创建者可以发言 
--     "announcement": null,
--     "name": "mychatroom",
--     "broadcasturl": "xxxxxx",
--     "onlineusercount": 1,
--     "ext": "",
--     "creator": "zhangsan"
--   },
--   "code": 200
-- }
-- --结果为json，服务端使用的话注意decode
ngx.say(res.body)