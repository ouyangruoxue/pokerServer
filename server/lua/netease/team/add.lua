--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:add.lua
--  功能:拉人进群
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	注意：所有群操作一个ip一分钟操作次数超过600次，会返回416错误码。
--  1.可以批量邀请，邀请时需指定群主；
--	2.当群成员达到上限时，再邀请某人入群返回失败；
--	3.当群成员达到上限时，被邀请人“接受邀请"的操作也将返回失败。
--]]

-- 参数说明
-- 参数		类型	必须	说明
-- tid		String	是		云信服务器产生，群唯一标识，创建群时会返回，最大长度128字符
-- owner	String	是		群主用户帐号，最大长度32字符
-- members	String	是		["aaa","bbb"](JSONArray对应的accid，如果解析出错会报414)，一次最多拉200个成员
-- magree	int		是		管理后台建群时，0不需要被邀请人同意加入群，1需要被邀请人同意才可以加入群。其它会返回414
-- msg		String	是		邀请发送的文字，最大长度150字符
-- attach	String	否		自定义扩展字段，最大长度512



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/team/add.action",{
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