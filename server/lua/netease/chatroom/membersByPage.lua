--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:membersByPage.lua
--  功能:分页获取成员列表
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  分页获取成员列表
--]]

-- 参数说明
-- 参数		类型	必须	说明
-- roomid	long	是		聊天室id
-- type		int		是		需要查询的成员类型,0:固定成员;1:非固定成员;2:仅返回在线的固定成员
-- endtime	long	是		单位毫秒，按时间倒序最后一个成员的时间戳,0表示系统当前时间
-- limit	long	是		返回条数，<=100



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/chatroom/membersByPage.action",{
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
--     "data": [
--        {
--           "roomid": 111,
--           "accid": "abc",
--           "nick": "abc",
--           "avator": "http://nim.nos.netease.com/MTAxMTAwMg==/bmltYV8xNzg4NTA1NF8xNDU2Mjg0NDQ3MDcyX2E4NmYzNWI5LWRhYWEtNDRmNC05ZjU1LTJhMDUyMGE5MzQ4ZA==",
--           "ext": "ext",
--           "type": "MANAGER",
--           "level": 2,
--           "onlineStat": true,
--           "enterTime": 1487145487971,
--           "blacklisted": true,
--           "muted": true,
--           "tempMuted": true,
--           "tempMuteTtl": 120,
--           "isRobot": true,
--           "robotExpirAt":120
--        }
--     ]
--   },
--   "code": 200
-- }

-- 返回结果中字段说明
-- 字段			类型	说明
-- roomid		long	聊天室id
-- accid		String	用户accid
-- nick			String	聊天室内的昵称
-- avator		String	聊天室内的头像
-- ext			String	开发者扩展字段
-- type			String	角色类型：
					--  UNSET（未设置），
					--  LIMITED（受限用户，黑名单或禁言），
					--  COMMON（普通固定成员），
					--  CREATOR（创建者），
					--  MANAGER（管理员），
					--  TEMPORARY（临时用户,非固定成员）
-- level		int		成员级别（若未设置成员级别，则无此字段）
-- onlineStat	Boolean	是否在线
-- enterTime	long	进入聊天室的时间点
-- blacklisted	Boolean	是否在黑名单中（若未被拉黑，则无此字段）
-- muted		Boolean	是否被禁言（若为被禁言，则无此字段）
-- tempMuted	Boolean	是否被临时禁言（若未被临时禁言，则无此字段）
-- tempMuteTtl	long	临时禁言的解除时长,单位秒（若未被临时禁言，则无此字段）
-- isRobot		Boolean	是否是聊天室机器人（若不是机器人，则无此字段）
-- robotExpirAt	int		机器人失效的时长，单位秒（若不是机器人，则无此字段）


ngx.say(res.body)