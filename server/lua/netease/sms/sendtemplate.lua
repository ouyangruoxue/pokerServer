--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:sendtemplate.lua
--  功能:发送短信验证码
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	发送短信验证码
--]]

-- 参数说明
-- 参数			类型	必须	说明
-- templateid	int		是	模板编号(由客户顾问配置之后告知开发者)
-- mobiles		String	是	接收者号码列表，JSONArray格式,如["186xxxxxxxx","186xxxxxxxx"]，限制接收者号码个数最多为100个
-- params		String	模板中若含变量则必须包含此参数	短信参数列表，用于依次填充模板，JSONArray格式，如["xxx","yyy"];对于不包含变量的模板，不填此参数表示模板即短信全文内容



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/sms/sendtemplate.action",{
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

--成功则在obj中返回此次发送的sendid(long),用于查询发送结果
-- "Content-Type": "application/json; charset=utf-8"
-- {
--   "code":200,
--   "msg":"sendid", 
--   "obj":123
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)