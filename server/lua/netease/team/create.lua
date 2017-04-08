--[[
--  作者:左笑林 
--  日期:2017-03-31
--  文件名:create.lua
--  功能:创建群
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--	注意：所有群操作一个ip一分钟操作次数超过600次，会返回416错误码。
--  创建高级群，以邀请的方式发送给用户；
--  custom 字段是给第三方的扩展字段，第三方可以基于此字段扩展高级群的功能，构建自己需要的群；
--  建群成功会返回tid，需要保存，以便于加人与踢人等后续操作；
--  每个用户可创建的群数量有限制，限制值由 IM 套餐的群组配置决定，可登录管理后台查看。
--]]

-- 参数说明
-- 参数				类型	必须	说明
-- tname			String	是		群名称，最大长度64字符
-- owner			String	是		群主用户帐号，最大长度32字符
-- members			String	是		["aaa","bbb"](JSONArray对应的accid，如果解析出错会报414)，一次最多拉200个成员
-- announcement		String	否		群公告，最大长度1024字符
-- intro			String	否		群描述，最大长度512字符
-- msg				String	是		邀请发送的文字，最大长度150字符
-- magree			int		是		管理后台建群时，0不需要被邀请人同意加入群，1需要被邀请人同意才可以加入群。其它会返回414
-- joinmode			int		是		群建好后，sdk操作时，0不用验证，1需要验证,2不允许任何人加入。其它返回414
-- custom			String	否		自定义高级群扩展属性，第三方可以跟据此属性自定义扩展自己的群属性。（建议为json）,最大长度1024字符
-- icon				String	否		群头像，最大长度1024字符
-- beinvitemode		int		否		被邀请人同意方式，0-需要同意(默认),1-不需要同意。其它返回414
-- invitemode		int		否		谁可以邀请他人入群，0-管理员(默认),1-所有人。其它返回414
-- uptinfomode		int		否		谁可以修改群资料，0-管理员(默认),1-所有人。其它返回414
-- upcustommode		int		否		谁可以更新群自定义属性，0-管理员(默认),1-所有人。其它返回414



local cjson = require "cjson"
local reqArgs = require "common.request_args"
local http = require "resty.http"
local neteaseHead =  require "netease.netease_header"
local httpc = http:new()


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()




local headr = neteaseHead.getNeteaseHttpHeadr(0)

local res, err = httpc:request_uri("https://api.netease.im/nimserver/team/create.action",{
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
--   "tid":"11001"
-- }
--结果为json，服务端使用的话注意decode
ngx.say(res.body)