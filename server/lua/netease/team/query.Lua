--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:query.lua
--  功能:群信息与成员列表查询
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	注意：所有群操作一个ip一分钟操作次数超过600次，会返回416错误码。
--  高级群信息与成员列表查询，一次最多查询30个群相关的信息，跟据ope参数来控制是否带上群成员列表；
--  查询群成员会稍微慢一些，所以如果不需要群成员列表可以只查群信息；
--  此接口受频率控制，某个应用一分钟最多查询30次，超过会返回416，并且被屏蔽一段时间；
--  群成员的群列表信息中增加管理员成员admins的返回。
--]]

-- 参数说明
-- 参数		类型	必须	说明
-- tids		String	是		群id列表，如["3083","3084"]
-- ope		int		是		1表示带上群成员列表，0表示不带群成员列表，只返回群信息



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/team/query.action",{
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
-- //查询不带群成员的群列表信息
-- {
--   "code":200,
--   "tinfos":
--     [
--  {"tname":"aa","announcement":"aa","owner":"v4","maxusers":50,
--       "joinmode":1,"tid":3083,"intro":"test","size":3, "custom":"", "mute":true},
--  {"tname":"bb","announcement":"bb","owner":"v4","maxusers":50,
--       "joinmode":1,"tid":3084,"intro":"test","size":3, "custom":"", "mute":false}
--     ]
-- }
-- //查询带群成员的群列表信息
-- {
--   "code":200,
--   "tinfos":
--     [
--       {"tname":"aa","announcement":"aa","owner":"v4","maxusers":50,
--       "joinmode":1,"tid":3083,"intro":"test","size":3,"custom":"",
-- "mute":true, "admins":["v3"]，"members":["v1","v2"]},
--       {"tname":"bb","announcement":"bb","owner":"v4","maxusers":50,
--       "joinmode":1,"tid":3084,"intro":"test","size":3,"custom":"",
-- "mute":false, "admins":["v3"]，"members":["v1","v2"]}
--     ]
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)