--[[
--  作者:左笑林 
--  日期:2017-03-30
--  文件名:setDonnop.lua
--  功能:设置桌面端在线时，移动端是否需要推送
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	设置桌面端在线时，移动端是否需要推送
--]]

-- 参数说明
-- 参数			类型	必须	说明
-- accid		String	是		用户帐号
-- donnopOpen	String	是		桌面端在线时，移动端是否不推送：true:移动端不需要推送，false:移动端需要推送

local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/user/setDonnop.action",{
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