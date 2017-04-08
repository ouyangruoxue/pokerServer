--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:querystatus.lua
--  功能:查询模板短信发送状态
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	根据短信的sendid(sendtemplate.action接口中的返回值)，查询短信发送结果。
--]]

-- 参数说明

-- 参数		类型	必须	说明
-- sendid	long	是		发送短信的编号sendid



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/sms/querystatus.action",{
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
--obj中返回JSONArray,格式如下(其中status取值:0-未发送,1-发送成功,2-发送失败,3-反垃圾)：
-- "Content-Type": "application/json; charset=utf-8"
-- {
--   "code": 200,
--   "obj": [
--     {
--       "status": 1,
--       "mobile": "13812341234",
--       "updatetime": 1471234567812
--     }
--   ]
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)