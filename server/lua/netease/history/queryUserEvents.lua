--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:queryUserEvents.lua
--  功能:用户登录登出事件记录查询
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  1.跟据时间段查询用户的登录登出记录，每次最多返回100条。
--	2.不提供分页支持，第三方需要跟据时间段来查询。
--]]

-- 参数说明
-- 参数			类型	必须	说明
-- accid		String	是	要查询用户的accid
-- begintime	String	是	开始时间，ms
-- endtime		String	是	截止时间，ms
-- limit		int		是	本次查询的消息条数上限(最多100条),小于等于0，或者大于100，会提示参数错误
-- reverse		int		否	1按时间正序排列，2按时间降序排列。其它返回参数414错误。默认是按降序排列




local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/history/queryUserEvents.action",{
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
-- 聊天室相关错误码	
-- 13001	IM主连接状态异常
-- 13002	聊天室状态异常
-- 13003	账号在黑名单中,不允许进入聊天室
-- 13004	在禁言列表中,不允许发言
-- "Content-Type": "application/json; charset=utf-8"
-- { 
--   "code":200, 
--   "size":xxx,--总共记录数 
--   "events": 
--   [ 
--     { 
--       "accid":"t4",    --用户accid 
--       "timestamp":1452058433412, --发生时间，ms 
--       "eventType":2,    --2表示登录，3表示登出 
--       "clientIp":"8.8.8.8", --用户clientip 
--       "sdkVersion":12, --sdk 版本 
--       "clientType":"IOS", --终端 
--       "code":200    --登录成功状态，200表示成功 
--     }, 
--     { 
--       "accid":"t4",    --用户accid 
--       "timestamp":1452058381580,    --发生时间，ms 
--       "eventType":3,    --2表示登录，3表示登出 
--       "clientIp":"8.8.8.8", --用户clientip 
--       "sdkVersion":12, --sdk 版本 
--       "clientType":"IOS", --终端 
--       "code":200    --登录成功状态，200表示成功 
--     } 
--   ] 
-- }
ngx.say(res.body)