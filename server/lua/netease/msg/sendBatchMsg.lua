--[[
--  作者:左笑林 
--  日期:2017-03-30
--  文件名:sendBatchMsg.lua
--  功能:批量发送点对点普通消息
--  1.给用户发送点对点普通消息，包括文本，图片，语音，视频，地理位置和自定义消息。
--  2.最大限500人，只能针对个人,如果批量提供的帐号中有未注册的帐号，会提示并返回给用户。
--  3.此接口受频率控制，一个应用一分钟最多调用120次，超过会返回416状态码，并且被屏蔽一段时间；
--]]

-- 参数说明
-- 参数				类型	必须	说明
-- fromAccid		String	是		发送者accid，用户帐号，最大32字符,必须保证一个APP内唯一
-- toAccids			String	是		["aaa","bbb"]（JSONArray对应的accid，如果解析出错，会报414错误），限500人
-- type				int		是		0 表示文本消息,
								--  1 表示图片，
								--  2 表示语音，
								--  3 表示视频，
								--  4 表示地理位置信息，
								--  6 表示文件，
								--  100 自定义消息类型
-- body				String	是	请参考下方消息示例说明中对应消息的body字段，最大长度5000字符，为一个json串
-- option			String	否	发消息时特殊指定的行为选项,Json格式，可用于指定消息的漫游，存云端历史，
							--  发送方多端同步，推送，消息抄送等特殊行为;option中字段不填时表示默认值 option示例:
							--  {"push":false,"roam":true,"history":false,"sendersync":true,"route":false,"badge":false,"needPushNick":true}
							--  字段说明：
							--  1. roam: 该消息是否需要漫游，默认true（需要app开通漫游消息功能）； 
							--  2. history: 该消息是否存云端历史，默认true；
							--  3. sendersync: 该消息是否需要发送方多端同步，默认true；
							--  4. push: 该消息是否需要APNS推送或安卓系统通知栏推送，默认true；
							--  5. route: 该消息是否需要抄送第三方；默认true (需要app开通消息抄送功能);
							--  6. badge:该消息是否需要计入到未读计数中，默认true;
							--  7. needPushNick: 推送文案是否需要带上昵称，不设置该参数时默认true;
-- pushcontent		String	否	ios推送内容，不超过150字符，option选项中允许推送（push=true），此字段可以指定推送内容
-- payload			String	否	ios 推送对应的payload,必须是JSON,不能超过2k字符
-- ext				String	否	开发者扩展字段，长度限制1024字符


local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)
local res, err = httpc:request_uri("https://api.netease.im/nimserver/msg/sendBatchMsg.action",{
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
-- "Content-Type": "application/json; charset=utf-8"
-- {
--   "code":200,
--	 "unregister":"["a","b"...]" //未注册的帐号
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)