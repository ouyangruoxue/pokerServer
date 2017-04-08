--[[
--  作者:左笑林 
--  日期:2017-03-29
--  文件名:update.lua
--  功能:更新好友相关信息
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	1.更新好友相关信息，如加备注名，必须是好友才可以
--]]

-- 参数说明

-- 参数		类型	必须	说明
-- accid	String	是		发起者accid
-- faccid	String	是		要修改朋友的accid
-- alias	String	否		给好友增加备注名，限制长度128
-- ex		String	否		修改ex字段，限制长度256

local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/friend/update.action",{
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