--[[
--  作者:左笑林 
--  日期:2017-03-30
--  文件名:updateUinfo.lua
--  功能:更新用户名片
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--]]

-- 参数说明
-- 参数		类型	必须	说明
-- accid	String	是	用户帐号，最大长度32字符，必须保证一个APP内唯一
-- name		String	否	用户昵称，最大长度64字符
-- icon		String	否	用户icon，最大长度1024字符
-- sign		String	否	用户签名，最大长度256字符
-- email	String	否	用户email，最大长度64字符
-- birth	String	否	用户生日，最大长度16字符
-- mobile	String	否	用户mobile，最大长度32字符，只支持国内号码
-- gender	int	否	用户性别，0表示未知，1表示男，2女表示女，其它会报参数错误
-- ex		String	否	用户名片扩展字段，最大长度1024字符，用户可自行扩展，建议封装成JSON字符串

local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/user/updateUinfo.action",{
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