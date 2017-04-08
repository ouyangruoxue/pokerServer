--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:recall.lua
--  功能:消息撤回
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	消息撤回接口，可以撤回一定时间内的点对点与群消息
--]]

-- 参数说明
-- 参数			类型	必须	说明
-- deleteMsgid	String	是		要撤回消息的msgid
-- timetag		long	是		要撤回消息的创建时间
-- type			int		是		7:表示点对点消息撤回，8:表示群消息撤回，其它为参数错误
-- from			String	是		发消息的accid
-- to			String	是		如果点对点消息，为接收消息的accid,如果群消息，为对应群的tid
-- msg			String	否		可以带上对应的描述
-- ignoreTime	String	否		1表示忽略撤回时间检测，其它为非法参数，如果需要撤回时间检测，不填即可



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/msg/recall.action",{
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
--   "url":"xxx"
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)