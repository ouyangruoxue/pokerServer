--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:sendMsg.lua
--  功能:发送聊天室消息
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  往聊天室内发消息
--]]

-- 参数说明
-- 参数				类型	必须	说明
-- roomid			long	是	聊天室id
-- msgId			String	是	客户端消息id，使用uuid等随机串，msgId相同的消息会被客户端去重
-- fromAccid		String	是	消息发出者的账号accid
-- msgType			int		是	消息类型：
							--  0: 表示文本消息， 
							--  1: 表示图片， 
							--  2: 表示语音， 
							--  3: 表示视频， 
							--  4: 表示地理位置信息，
							--  6: 表示文件，
							--  10: 表示Tips消息，
							--  100: 自定义消息类型
-- resendFlag		int		否	重发消息标记，0：非重发消息，1：重发消息，如重发消息会按照msgid检查去重逻辑
-- attach			String	否	消息内容，格式同消息格式示例中的body字段,长度限制4096字符
-- ext				String	否	消息扩展字段，内容可自定义，请使用JSON格式，长度限制4096字符
-- antispam			String	否	本消息是否需要过自定义反垃圾系统。true或false, 默认false
-- antispamCustom	String	否	自定义的反垃圾内容, JSON格式，长度限制同attach字段，不能超过4096字符，antispamCustom示例：
							--  {"type":1,"data":"custom content"}
							--  字段说明：
							--  1. type: 1:文本，2：图片，3视频;
							--  2. data: 文本内容or图片地址or视频地址。




local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/chatroom/sendMsg.action",{
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
--   "desc":{
--     "time": "1456396333115", 
--     "fromAvator":"http://b12026.nos.netease.com/MTAxMTAxMA==/bmltYV84NDU4OF8xNDU1ODczMjA2NzUwX2QzNjkxMjI2LWY2NmQtNDQ3Ni0E2LTg4NGE4MDNmOGIwMQ==",
--     "msgid_client": "c9e6c306-804f-4ec3-b8f0-573778829419",
--     "fromClientType": "REST",
--     "attach": "This+is+test+msg",
--     "roomId": "36",
--     "fromAccount": "zhangsan",
--     "fromNick": "张三",
--     "type": "0",
--     "ext": ""
--   } 
-- }
ngx.say(res.body)