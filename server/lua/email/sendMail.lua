--[[
--  作者:zuoxiaolin 
--  日期:2017-03-12
--  文件名:email/sendMail.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  lua邮件发送的实现
--  date: 2017.03.12
--]]

-- smtp方法发送mail
local smtp = require("smtp")
local cjson = require "cjson"

local _M = {}
_M._VERSION = '0.01'            
local mt = { __index = _M }                    


local from = "<zuo_xiao_lin@126.com>" -- 发件人

-- 发送列表
local rcpt = {
	"<zuo_xiao_lin@126.com>" ,
	"<459575602@qq.com>"
}

local mesgt = {
	headers = {
		to = "zuo_xiao_lin@163.com", -- 收件人
		cc = '<459575602@qq.com>', -- 抄送
		subject = 'hello',
	},
	--自己拼接
	body = "<p>验证码为：783234</p><a href=\"#\">欢迎访问</a>"
}
mesgt.headers["content-type"] = 'text/html; charset="utf-8"'



local mailt = {
	server="smtp.126.com",
	user="zhaomangzheng@126.com",
	password="binshared",
	from = from,
	rcpt = rcpt,
--	source = smtp:message(mesgt)
	mesgt = mesgt
}


--[[
-- 定义邮件发送的方法
-- -- 发送列表
local rcpt = {
	"<zuo_xiao_lin@126.com>" ,
	"<459575602@qq.com>"
}

local mesgt = {
	headers = {
		to = "zuo_xiao_lin@163.com", -- 收件人
		cc = '<459575602@qq.com>', -- 抄送
		subject = 'hello',
	},
	--自己拼接
	body = "<p>验证码为：783234</p><a href=\"#\">欢迎访问</a>"
}
mesgt.headers["content-type"] = 'text/html; charset="utf-8"'



local mailt = {
	server="smtp.126.com",
	user="zhaomangzheng@126.com",
	password="binshared",
	from = from,
	rcpt = rcpt,
--	source = smtp:message(mesgt)
	mesgt = mesgt
}
       
-- @param mailt 包含上述内容
--]]
local function _M.sendMail(mailt)

local s = smtp:new(mailt.server, mailt.port, mailt.create)
local ext = s:greet(mailt.domain)

local auth = s:auth(mailt.user, mailt.password, ext)

--local source = s:message(mesgt)
--mailt.source = source

local BACK_STRING = "success"
local code, reply = s:send(mailt)
if not code then
	ngx.log(ngx.ERR, "mail send error: ", reply)
	BACK_STRING = "fail"
end
s:quit()
s:close()

ngx.req.set_header('Content-Type', "json")
local rt = {}
	rt.msg = BACK_STRING
ngx.say(cjson.encode(rt))
return rt
end

return _M




