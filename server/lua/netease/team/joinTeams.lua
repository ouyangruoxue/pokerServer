--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:joinTeams.lua
--  功能:获取某用户所加入的群信息
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	注意：所有群操作一个ip一分钟操作次数超过600次，会返回416错误码。
--  获取某用户所加入的群信息
--]]

-- 参数说明
-- 参数		类型	必须	说明
-- accid	String	是		要查询用户的accid



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/team/joinTeams.action",{
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
--"Content-Type": "application/json; charset=utf-8"
-- {   "code":200 ,
--     "count":2,
--     "infos":
--       [
--           {"owner":"t2","tname":"test1","maxusers":50,"tid":3620,"size":3, "custom":""},
--           {"owner":"t1","tname":"test2","maxusers":50,"tid":3622,"size":4, "custom":""}
--       ]
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)