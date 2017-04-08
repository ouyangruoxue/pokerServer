--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:setMemberRole.lua
--  功能:设置聊天室内用户角色
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  设置聊天室内用户角色
--]]

-- 参数说明
-- 参数			类型	必须	说明
-- roomid		long	是	聊天室id
-- operator		String	是	操作者账号accid
-- target		String	是	被操作者账号accid
-- opt			int		是	操作：
						--  1: 设置为管理员，operator必须是创建者 
						--  2:设置普通等级用户，operator必须是创建者或管理员 
						-- -1:设为黑名单用户，operator必须是创建者或管理员 
						-- -2:设为禁言用户，operator必须是创建者或管理员
-- optvalue		String	是	true或false，true:设置；false:取消设置
-- notifyExt	String	否	通知扩展字段，长度限制2048，请使用json格式




local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/chatroom/setMemberRole.action",{
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
--"Content-Type": "application/json; charset=utf-8"
-- {
--   "desc": {
--     "roomid": 16,
--     "level": 10,
--     "accid": "zhangsan",
--     "type": "COMMON"
--   },
--   "code": 200
-- }

-- 备注：
-- 返回的type字段可能为：
--         LIMITED,          //受限用户,黑名单+禁言 
--         COMMON,           //普通固定成员
--         CREATOR,          //创建者 
--         MANAGER,          //管理员 
--         TEMPORARY,        //临时用户,非固定成员
-- --结果为json，服务端使用的话注意decode
ngx.say(res.body)