--[[
--  作者:左笑林 
--  日期:2017-03-30
--  文件名:getUinfos.lua
--  功能:获取用户名片
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	1.获取用户名片，可批量
--]]

-- 参数说明
-- 参数		类型	必须	说明
-- accids	String	是		用户帐号（例如：JSONArray对应的accid串，如：["zhangsan"]，如果解析出错，会报414）（一次查询最多为200）

local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/user/getUinfos.action",{
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
--   "uinfos":
--      [
--       {"email":"t1@163.com","accid":"t1","name":"abc","gender":1,"mobile":"18645454545"},
--       {"accid":"t2","name":"def","gender":0}
--      ]
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)