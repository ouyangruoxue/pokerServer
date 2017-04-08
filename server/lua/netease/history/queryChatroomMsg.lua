--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:queryChatroomMsg.lua
--  功能:聊天室云端历史消息查询
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  1.此接口有频控限制，每分钟可调用不超过1200次
--]]

-- 参数说明
-- 参数		类型	必须	说明
-- roomid	long	是		聊天室id
-- accid	String	是		用户账号
-- timetag	long	是		查询的时间戳锚点，13位。reverse=1时timetag为起始时间戳，reverse=2时timetag为终止时间戳
-- limit	int		是		本次查询的消息条数上限(最多200条),小于等于0，或者大于200，会提示参数错误
-- reverse	int		否		1按时间正序排列，2按时间降序排列。其它返回参数414错误。默认是2按时间降序排列




local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/history/queryChatroomMsg.action",{
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
--   "code":200,
--   "size":xxx,//总共消息条数
--   "msgs":[各种类型的消息参见"历史消息查询返回的消息格式说明",JSONArray]  // 其中的msgid字段为客户端消息id，对应单聊和群群云端历史消息中的msgid为服务端消息id
-- }
ngx.say(res.body)