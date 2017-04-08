--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:queueOffer.lua
--  功能:往聊天室有序队列中新加或更新元素
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  往聊天室有序队列中新加或更新元素
--]]

-- 参数说明
-- 参数		类型	必须	说明
-- roomid	long	是		聊天室id
-- key		String	是		elementKey,新元素的UniqKey,长度限制128字符
-- value	String	是		elementValue,新元素内容，长度限制4096字符




local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/chatroom/queueOffer.action",{
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
--   },
--   "code": 200
-- }
ngx.say(res.body)