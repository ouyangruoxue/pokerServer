--[[
--  作者:左笑林 
--  日期:2017-03-30
--  文件名:sendMsg.lua
--  功能:发送普通消息
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	给用户或者高级群发送普通消息，包括文本，图片，语音，视频和地理位置，具体消息参考下面描述
--]]

-- 参数说明
-- 参数				类型	必须	说明
-- from				String	是		发送者accid，用户帐号，最大32字符，必须保证一个APP内唯一
-- ope				int		是		0：点对点个人消息，1：群消息（高级群），其他返回414
-- to				String	是		ope==0是表示accid即用户id，ope==1表示tid即群id
-- type				int		是		0 表示文本消息, 1 表示图片，2 表示语音，3 表示视频， 4 表示地理位置信息， 6 表示文件， 100 自定义消息类型
-- body				String	是		请参考下方消息示例说明中对应消息的body字段， 最大长度5000字符，为一个JSON串
-- antispam			String	否		本消息是否需要过自定义反垃圾系统，true或false, 默认false
-- antispamCustom	String	否		自定义的反垃圾内容, JSON格式，长度限制同body字段，不能超过5000字符，
								--	antispamCustom示例：{"type":1,"data":"custom content"} 
								--	字段说明： 1. type: 1:文本，2：图片，3视频; 2. data: 文本内容or图片地址or视频地址。
-- option			String	否		发消息时特殊指定的行为选项,JSON格式，可用于指定消息的漫游，存云端历史，发送方多端同步，
								--	推送，消息抄送等特殊行为;option中字段不填时表示默认值 ，option示例:
								-- {"push":false,"roam":true,"history":false,"sendersync":true,"route":false,"badge":false,"needPushNick":true}
								-- 字段说明：
								-- 1. roam: 该消息是否需要漫游，默认true（需要app开通漫游消息功能）； 
								-- 2. history: 该消息是否存云端历史，默认true；
								--  3. sendersync: 该消息是否需要发送方多端同步，默认true；
								--  4. push: 该消息是否需要APNS推送或安卓系统通知栏推送，默认true；
								--  5. route: 该消息是否需要抄送第三方；默认true (需要app开通消息抄送功能);
								--  6. badge:该消息是否需要计入到未读计数中，默认true;
								-- 7. needPushNick: 推送文案是否需要带上昵称，不设置该参数时默认true;
								-- 8. persistent: 是否需要存离线消息，不设置该参数时默认true。

-- pushcontent		String	否	ios推送内容，不超过150字符，option选项中允许推送（push=true），此字段可以指定推送内容
-- payload			String	否	ios 推送对应的payload,必须是JSON,不能超过2k字符
-- ext				String	否		开发者扩展字段，长度限制1024字符
-- forcepushlist	String	否	发送群消息时的强推（@操作）用户列表，格式为JSONArray，如["accid1","accid2"]。若forcepushall为true，则forcepushlist为除发送者外的所有有效群成员
-- forcepushcontent	String	否	发送群消息时，针对强推（@操作）列表forcepushlist中的用户，强制推送的内容
-- forcepushall		String	否	发送群消息时，强推（@操作）列表是否为群里除发送者外的所有有效成员，true或false，默认为false



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/msg/sendMsg.action",{
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
--   "code":200
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)