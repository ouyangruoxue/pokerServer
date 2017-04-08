
--[[
--  作者:左笑林 
--  日期:2017-03-29
--  文件名:netease_headr.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
-- 本文件主要用于初始化网易云的http请求头
-- 主要包含以下信息
--AppKey	开发者平台分配的appkey
--Nonce	随机数（最大长度128个字符）
--CurTime	当前UTC时间戳，从1970年1月1日0点0 分0 秒开始到现在的秒数(String)
--CheckSum	SHA1(AppSecret + Nonce + CurTime),三个参数拼接的字符串，进行SHA1哈希计算，转化成16进制字符(String，小写)
--封装好http头文件用来给其他跟网易云的交互使用
--]]

local str = require "resty.string"
local uuid = require 'resty.jit-uuid'
local resty_sha1 = require "resty.sha1"
local _M = {}
--[[
	封装云信http头
	@parm secondOrMillisecond 0 curtime 取到秒 1取毫秒
--]]
function _M.getNeteaseHttpHeadr(secondOrMillisecond)
--contenttype
local ContentType = "application/x-www-form-urlencoded;charset=utf-8"
local headers = { ["Content-Type"]=ContentType}

--appkey
local appkey = "93c2730be068bfa8557eca30c56287bb"
headers.AppKey = appkey

--AppSecret

local AppSecret = "654c76f5348b"
--CurTime
ngx.update_time()
local curtime = nil
if secondOrMillisecond == 0 then
	curtime = os.time()
 else
 	curtime = ngx.now()
 end	

headers.CurTime = curtime
-- Nonce	随机数
local tSec = ngx.now()
uuid.seed(tSec)
local nonce = uuid()
headers.Nonce = nonce


local check_sum = string.format("%s%s%s",AppSecret,nonce,curtime)

local sha1 = resty_sha1:new()
  if not sha1 then
      ngx.say("failed to create the sha1 object")
      return nil
  end

local ok = sha1:update(check_sum)
  if not ok then
      ngx.say("failed to add data")
      return nil
  end
    --返回sha1结果
local digest = sha1:final()  -- binary digest
    --转16进制
local checksumByte = str.to_hex(digest)

headers.CheckSum = checksumByte


return headers

end

return _M