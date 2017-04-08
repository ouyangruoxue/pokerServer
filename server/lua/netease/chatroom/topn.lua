--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:topn.lua
--  功能:查询聊天室统计指标TopN
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  1、根据时间戳，按指定周期列出聊天室相关指标的TopN列表 
	2、当天的统计指标需要到第二天才能查询
--]]

-- 参数说明
-- 参数			类型	必须	说明
-- topn			int		否		topn值，可选值 1~500，默认值100
-- timestamp	long	否		需要查询的指标所在的时间坐标点，不提供则默认当前时间，单位秒/毫秒皆可
-- period		String	否		统计周期，可选值包括 hour/day, 默认hour
-- orderby		String	否		取排序值,可选值 active/enter/message,分别表示按日活排序，进入人次排序和消息数排序， 默认active



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/chatroom/topn.action",{
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
--   "code": 200,
--   "data": [
--     {
--       "activeNums": 5955,       // 该聊天室内的活跃数
--       "datetime": 1471712400,   // 统计时间点，单位秒，按天统计的是当天的0点整点；按小时统计的是指定小时的整点
--       "enterNums": 18621,       // 进入人次数量
--       "msgs": 2793,             // 聊天室内发生的消息数
--       "period": "HOUR",         // 统计周期，HOUR表示按小时统计；DAY表示按天统计
--       "roomId": 3571337         // 聊天室ID号
--     },
--     {
--       "activeNums": 6047,
--       "datetime": 1471708800,
--       "enterNums": 15785,
--       "msgs": 2706,
--       "period": "HOUR",
--       "roomId": 3573737
--     },
--     {
--       "activeNums": 5498,
--       "datetime": 1471708800,
--       "enterNums": 14590,
--       "msgs": 2258,
--       "period": "HOUR",
--       "roomId": 3513774
--     }
--   ]
-- }
ngx.say(res.body)