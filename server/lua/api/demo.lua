local cjson = require "cjson"
local userDb = require "db.base_db"
local req = require "common.request_args"
local redis = require "redis.zs_redis"
local responseData = require "common.api_data_help"
local randomname = require "game.TexasHoldem.player_robot_name"
local uuid = require 'resty.jit-uuid'
require "init.lua_func_ex"
local red = redis:new()



-- local usercode1 = {}
-- usercode1.name="xxxx"
-- usercode1.balance = 12

-- local usercode2 = {}
-- usercode2.name="xx4"
-- usercode2.balance = 13



--   local function compare(x, y) --从大到小排序
--      return x.balance > y.balance         --如果第一个参数大于第二个就返回true，否则返回false
--   end
--  --table.sort(temp.week,compare)
--  local ok, err = red:hmset("giftrank_1_week","usercode2",cjson.encode(usercode2))
--  local ok, err = red:hmset("giftrank_1_week","usercode1",cjson.encode(usercode1))


-- local ok,err =red:expire("giftrank_1_week",15)
-- ngx.say(cjson.encode(ok))

--  local res,err = red:hgetall("giftrank_1_week")
-- -- local result = cjson.decode(res[1])

--  local tabletest = table.array2rcordForJson(res)

-- local function getTableTenData(srctable)
-- 	local temp = {}
-- 	local index = 1
-- 	for k,v in pairs(srctable) do
-- 		temp[index] = v
-- 		index = index +1
-- 	end
-- 	table.sort( temp, compare)

-- 	local  result = {}

-- 	for i=1,10 do
-- 		if temp[i] then
-- 			result[i] = temp[i]
-- 		else
-- 			break
-- 		end
-- 	end

-- 	return result
-- end

-- local test =  getTableTenData(tabletest)
-- -- local name = tabletest["name"]
-- -- --table.sort(name,compare)

--  -- ngx.say(cjson.encode(res))
--   ngx.say(cjson.encode(test))
 -- ngx.say(cjson.encode(result))
-- if not ok then
    -- ngx.say("failed to set dog: ", err)
    -- return
-- end
-- ngx.say("set result: ", ok)
--设置删除时间15秒
-- local res2 err2 = red:expire("dog",15)
-- ngx.say("set dog: ", res2)
-- ngx.say("set dog: ", err2)

-- local res1, errdog = red:get("dog")
                -- if not res1 then
                    -- ngx.say("failed to get dog: ", errdog)
                    -- return
                -- end
-- ngx.say("set dog: ", res1)



    ngx.update_time()


    local tSec = ngx.now()
    uuid.seed(tSec)
    local msgid = uuid()

    local ext = {}

    ext.betRank = {}

    ext.onlineNum = 5

    local caputureAgrs = {}
    caputureAgrs.fromAccid = 3
    caputureAgrs.roomid = 8276185
    caputureAgrs.msgType = 100
    caputureAgrs.msgId = msgid
    caputureAgrs.attach = "31312313123"
    local  captureRes = ngx.location.capture(
                    '/netease/chatroom/sendMsg',
                     { method = ngx.HTTP_POST,body = ngx.encode_args(caputureAgrs)}
    )
    --ngx.say(cjson.encode(captureRes))
    local captureTab,err = cjson.decode(captureRes.body)
    if tonumber(captureTab.code) ~= 200 then
        result = responeData.new_failed(res,zhCn_bundles.login_connect_chatroom_error)
        ngx.say(cjson.encode(result))
            return
    end 

    if err then
        ngx.say(cjson.encode(err))
    end    

    ngx.say(captureRes.body)

-- local userParm = {}
-- userParm.gift_number = 1
-- local userDbOp = userDb.new();
-- local res,err = userDbOp.getBaseFromSql("t_gift_record",userParm)
-- if not res then
-- 		ngx.say("no result")
-- 		return  
-- end




-- ngx.say(cjson.encode(res))
-- require "netease.netease_header"

-- local result = getNeteaseHttpHeadr(0)

-- ngx.say(cjson.encode(result))

-- ngx.say(cjson.encode(os.time()))

 -- local result2 = getSecDistancToNextMonthFirstDay()

 
 -- local currentTimeTable = os.date("*t") 

 -- ngx.say(cjson.encode(result1))
 -- ngx.say(cjson.encode(result2))

