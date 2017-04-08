--[[
--  作者:左笑林 
--  日期:2017-03-30
--  文件名:sendBatchAttachMsg.lua
--  功能:批量发送点对点自定义系统通知
--  1.系统通知区别于普通消息，应用接收到直接交给上层处理，客户端可不做展示；
--  2.目前支持类型：点对点类型；
--  3.最大限500人，只能针对个人,如果批量提供的帐号中有未注册的帐号，会提示并返回给用户；
--  4.此接口受频率控制，一个应用一分钟最多调用120次，超过会返回416状态码，并且被屏蔽一段时间；
	应用场景：如某个用户给另一个用户发送好友请求信息等，具体attach为请求消息体，第三方可以自行扩展，建议是json格式
--]]

-- 参数说明

-- 参数			类型	必须	说明
-- fromAccid	String	是		发送者accid，用户帐号，最大32字符，APP内唯一
-- toAccids		String	是		["aaa","bbb"]（JSONArray对应的accid，如果解析出错，会报414错误），最大限500人
-- attach		String	是		自定义通知内容，第三方组装的字符串，建议是JSON串，最大长度4096字符
-- pushcontent	String	否		iOS推送内容，第三方自己组装的推送内容,不超过150字符
-- payload		String	否		iOS推送对应的payload,必须是JSON,不能超过2k字符
-- sound		String	否		如果有指定推送，此属性指定为客户端本地的声音文件名，长度不要超过30个字符，如果不指定，会使用默认声音
-- save			int		否		1表示只发在线，2表示会存离线，其他会报414错误。默认会存离线
-- option		String	否		发消息时特殊指定的行为选项,Json格式，可用于指定消息计数等特殊行为;option中字段不填时表示默认值。
							--  option示例：
							--  {"badge":false,"needPushNick":false,"route":false}
							--  字段说明：
							--  1. badge:该消息是否需要计入到未读计数中，默认true;
							--  2. needPushNick: 推送文案是否需要带上昵称，不设置该参数时默认false(ps:注意与sendBatchMsg.action接口有别)。
							--  3. route: 该消息是否需要抄送第三方；默认true (需要app开通消息抄送功能)


local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/msg/sendBatchAttachMsg.action",{
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