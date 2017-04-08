--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:update.lua
--  功能:编辑群资料
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	注意：所有群操作一个ip一分钟操作次数超过600次，会返回416错误码。
--  高级群基本信息修改！
--]]

-- 参数说明
-- 参数			类型	必须	说明
-- tid			String	是		云信服务器产生，群唯一标识，创建群时会返回
-- tname		String	否		群名称，最大长度64字符
-- owner		String	是		群主用户帐号，最大长度32字符
-- announcement	String	否		群公告，最大长度1024字符
-- intro		String	否		群描述，最大长度512字符
-- joinmode		int		否		群建好后，sdk操作时，0不用验证，1需要验证,2不允许任何人加入。其它返回414
-- custom		String	否		自定义高级群扩展属性，第三方可以跟据此属性自定义扩展自己的群属性。（建议为json）,最大长度1024字符
-- icon			String	否		群头像，最大长度1024字符
-- beinvitemode	int		否		被邀请人同意方式，0-需要同意(默认),1-不需要同意。其它返回414
-- invitemode	int		否		谁可以邀请他人入群，0-管理员(默认),1-所有人。其它返回414
-- uptinfomode	int		否		谁可以修改群资料，0-管理员(默认),1-所有人。其它返回414
-- upcustommode	int		否		谁可以更新群自定义属性，0-管理员(默认),1-所有人。其它返回414



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)
local res, err = httpc:request_uri("https://api.netease.im/nimserver/team/update.action",{
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
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)