--[[
--  作者:左笑林 
--  日期:2017-03-30
--  文件名:create.lua
--  功能:创建云信ID
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	1.第三方帐号导入到云信平台；
--	2.注意accid，name长度以及考虑管理token。
--]]

-- 参数说明
-- 参数	类型		必须	说明
-- accid	String	是	云信ID，最大长度32字符，必须保证一个APP内唯一（只允许字母、数字、半角下划线_、 @、半角点以及半角-组成，不区分大小写， 会统一小写处理，请注意以此接口返回结果中的accid为准）。
-- name		String	否	云信ID昵称，最大长度64字符，用来PUSH推送时显示的昵称
-- props	String	否	json属性，第三方可选填，最大长度1024字符
-- icon		String	否	云信ID头像URL，第三方可选填，最大长度1024
-- token	String	否	云信ID可以指定登录token值，最大长度128字符， 并更新，如果未指定，会自动生成token，并在创建成功后返回

local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()


local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/user/create.action",{
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
--   "info":{"token":"xx","accid":"xx","name":"xx"} 
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)