local cjson = require "cjson"
local dbbase = require "db.base_db"
local reqArgs = require "common.request_args"
local redis = require "redis.zs_redis"
local systemConf = require "common.systemconfig"
local resty_md5 = require "resty.md5"
local str = require "resty.string"
local uuid = require 'resty.jit-uuid'
local http = require "resty.http"
local respone = require "common.api_data_help"

local httpc = http:new()
local red = redis:new()
local userDbOp = userDb:new();


--[[微信登录--]]

local function wechatlogin(loginparm)
	-- body
end

				
local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()
--登录方式
-- local logintype = args["logintype"]
-- ngx.say(zhCn_bundles.db_no_parm)
-- if not args["code"] then
-- 	local  result = respone.new_failed({},zhCn_bundles.db_no_parm)
--         ngx.say(cjson.encode(result))
--     return
-- end

--获取access_token
local res, err = httpc:request_uri("https://api.weixin.qq.com/sns/oauth2/access_token", {
        method = "GET",
        query = {
                grant_type = "authorization_code",
                appid = "wx5dd7a03e3fe86262", --填写自己的appid
                secret = "9b47297518f953376dec0c5b0697dd42", -- 填写自己的secret
                code = args["code"],
        },
        ssl_verify = false, -- 需要关闭这项才能发起https请求
        headers = {["Content-Type"] = "application/x-www-form-urlencoded" },
      })

if not res then
        local  result = respone.new_failed({},err)
        ngx.say(cjson.encode(result))
        return
end

-- if not res.access_token then
--         local  result = respone.new_failed({},"invalid code")
--         ngx.say(cjson.encode(result))
--         return
-- end
ngx.status = res.status
ngx.say(res.body)




--验证access_token是否有效
res, err = httpc:request_uri("https://api.weixin.qq.com/sns/auth", {
        method = "GET",
        query = {
                access_token = res["access_token"],
                openid = res["openid"], --用户openid
        },
        ssl_verify = false, -- 
        headers = {["Content-Type"] = "application/x-www-form-urlencoded" },
      })
if not res then
        ngx.say("failed to request: ", err)
        return
end

--获取用户信息
res, err = httpc:request_uri("https://api.weixin.qq.com/sns/userinfo", {
        method = "GET",
        query = {
                access_token = res["access_token"],
                openid = res["openid"], --
        },
        ssl_verify = false, -- 
        headers = {["Content-Type"] = "application/x-www-form-urlencoded" },
      })
if not res then
        ngx.say("failed to request: ", err)
        return
end









