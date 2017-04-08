--[[
----@parm send_user_code 发送人用户编号
----@parm rec_user_code 主播编号
----@parm gift_type_id_fk 礼物编号
----@parm gift_value 礼物价值（单价）
----@parm gift_number 礼物数量
----@parm nickname 送礼人昵称
----@parm is_join_share 是否参与主播分红（是的话就进行主播balance的更新）
----@parm channel_id_fk 渠道商id后续有用
上面为必给参数
下面不强制
----@parm head_icon 用户头像
--下面不给的话需要客户端自己本地取
----@parm gift_name 礼物名称
----@parm gift_logo 礼物图标
--]]

require "init.lua_func_ex"
local redis = require "redis.zs_redis"
local cjson = require "cjson"
local reqArgs = require "common.request_args"
local responeData = require "common.api_data_help"
local multiDb = require "db.user.multi_sqlTab_db"
local baseDb = require "db.base_db"


local currentRequestArgs = reqArgs.new()
local args = currentRequestArgs.getArgs()

if  not args.send_user_code or not args.rec_user_code or not args.gift_name or not args.gift_type_id_fk or not args.gift_value or 
not args.gift_number  then 
local  result = responeData.new_failed({},zhCn_bundles.db_parm_error)
ngx.say(cjson.encode(result))
return	
end


local multiDbOp = multiDb.new()

local gift_record ={}
--gift_record.gift_time = os.date("%Y-%m-%d %H:%M:%S")
local gift_rank_value = {}
local gift_rank_num = {}
--发送人
if  args.send_user_code and args.send_user_code ~= "" then 
gift_record.send_user_code = args.send_user_code
gift_rank_value.send_user_code = args.send_user_code
end

if  args.gift_logo and args.gift_logo ~= "" then 
	gift_rank_num.gift_logo = args.gift_logo
end

if  args.head_icon and args.head_icon ~= "" then 
	gift_rank_value.head_icon = args.head_icon
end


--接收人
if  args.rec_user_code and args.rec_user_code ~= "" then 
	gift_record.rec_user_code = args.rec_user_code
	gift_rank_value.rec_user_code = args.rec_user_code
	gift_rank_num.rec_user_code = args.rec_user_code
    --主播id
    gift_rank_value.anchorId = args.rec_user_code
    gift_rank_num.anchorId = args.rec_user_code
end
if  args.gift_type_id_fk and args.gift_type_id_fk ~= ""  then 
	gift_record.gift_type_id_fk = args.gift_type_id_fk
	gift_rank_num.gift_type_id_fk = args.gift_type_id_fk
end
--礼物数量
if  args.gift_number and args.gift_number ~= ""  then 
	gift_record.gift_number = args.gift_number
	gift_rank_num.gift_number = args.gift_number
end


--礼物价值
if args.gift_number and args.gift_number ~= "" and args.gift_value and args.gift_value ~= "" then
	gift_rank_value.gift_total_value = tonumber(args.gift_number)*tonumber(args.gift_value)
    gift_rank_num.gift_value = args.gift_value
end	
--发送人昵称
if  args.nickname and args.nickname ~= ""  then 
	gift_rank_value.nickname = args.nickname
	gift_rank_num.nickname = args.nickname
end
--礼物名称
if  args.gift_name and args.gift_name ~= ""  then 
	gift_rank_num.gift_name = args.gift_name
end



--[[
    -- gifr/send_gift.lua
-- 计算距离下周一号剩余的时间
--
-- Author: zuoxiaolin
-- 2017.03.20

--]]
function getSecDistancToNextday()
    
    local currentTimeTable = os.date("*t") 

    --获取当前时间在一天当中的小时24小时制
    local hour = currentTimeTable["hour"]
    --获取当前时间分钟数
    local min = currentTimeTable["min"]
    --获取当前时间秒钟数
    local sec = currentTimeTable["sec"]
    --获取分钟差距
    local mindistance = 59-min
    --获取距离整分秒数差距
    local secdistance = 60 - sec

    --获取距离零点差距
    local hourdistance = 23 - hour

    --得到总时间差（秒）
    local totalDistanceSec = hourdistance*3600+mindistance*60+secdistance

    return totalDistanceSec
end


--[[
    -- gifr/send_gift.lua
-- 计算距离下周一号剩余的时间
--
-- Author: zuoxiaolin
-- 2017.03.20

--]]
function getSecDistancToNextWednesday()
    
    local currentTimeTable = os.date("*t") 
    --获取一星期中的第几天[1 ~ 7 = 星期天 ~ 星期六]
    local wday = currentTimeTable["wday"]
    --获取当前时间在一天当中的小时24小时制
    local hour = currentTimeTable["hour"]
    --获取当前时间分钟数
    local min = currentTimeTable["min"]
    --获取当前时间秒钟数
    local sec = currentTimeTable["sec"]
    --获取分钟差距
    local mindistance = 59-min
    --获取距离整分秒数差距
    local secdistance = 60 - sec

    --获取距离零点差距
    local hourdistance = 23 - hour

    --获取到下周一的天数差距
    local daydistance = 8 - wday

    --得到总时间差（秒）
    local totalDistanceSec = daydistance*24*3600+hourdistance*3600+mindistance*60+secdistance

    return totalDistanceSec
end

--[[
    -- gifr/send_gift.lua
-- 计算距离下月一号剩余的时间
--
-- Author: zuoxiaolin
-- 2017.03.20

--]]
function getSecDistancToNextMonthFirstDay()
    
    local currentTimeTable = os.date("*t")

    --获取年份
    local year = currentTimeTable["year"]
    --获取月份
    local month = currentTimeTable["month"]
    --获取每个月中的第几天
    local day = currentTimeTable["day"]
    --获取当前时间在一天当中的小时24小时制
    local hour = currentTimeTable["hour"]
    --获取当前时间分钟数
    local min = currentTimeTable["min"]
    --获取当前时间秒钟数
    local sec = currentTimeTable["sec"]
    --获取分钟差距
    local mindistance = 59-min
    --获取距离整分秒数差距
    local secdistance = 60 - sec

    --获取距离零点差距
    local hourdistance = 23 - hour
    local daydistance = nil
    --获取到下周一的天数差距
    if month == 1 or month ==3  or month == 5 or month == 7 or
       month == 8 or month ==10 or month ==12 then
        daydistance = 31 - day
    elseif month == 4 or month ==6  or month == 9 or month ==11  then
        daydistance = 30 - day
    else 
        if(year%4==0 and year%100~=0) or year%400==0 then
            daydistance = 29 - day
        else
            daydistance = 28 - day
        end 

    end

    local totalDistanceSec = daydistance*24*3600+hourdistance*3600+mindistance*60+secdistance

    return totalDistanceSec
end



--[[主播收到各种礼物的价值]]
local function  anchorReceiveGiftsValue (recgift)
	--判空
	local red = redis:new()
	--周榜相关处理
	local giftweek = red:hmget("giftrank_value_"..recgift.anchorId.."_week",recgift.send_user_code)

	if not giftweek then

		local ok, err = red:hmset("giftrank_value_"..recgift.anchorId.."_week",recgift.send_user_code,cjson.encode(recgift))
		if not ok then  
			ngx.log(ngx.ERR,"giftweek insert err")
		end

	else
    		 --获取原周礼物数据
    		 local resultweek = cjson.decode(giftweek[1])
             if not resultweek then
                local ok, err = red:hmset("giftrank_value_"..recgift.anchorId.."_week",recgift.send_user_code,cjson.encode(recgift))
                if not ok then  
                 ngx.log(ngx.ERR,"giftweek insert err")
                 end
             else
                local pre_week_gift_total_value = resultweek["gift_total_value"]; 

                local new_week_gift_total_value = recgift["gift_total_value"]; 
                --进行累计
                local total_week_gift_value = tonumber(pre_week_gift_total_value)+tonumber(new_week_gift_total_value)

                resultweek["gift_total_value"] = total_week_gift_value
                resultweek["nickname"] = recgift["nickname"]
                --再存储
 
                 local ok,err = red:hmset("giftrank_value_"..recgift.anchorId.."_week",recgift.send_user_code,cjson.encode(resultweek))
                  if not ok then  
                    ngx.log(ngx.ERR,"giftweek insert err",err)
                  end
             end   
    		 
      
    end	

    --月榜相关处理
    local giftmonth = red:hmget("giftrank_value_"..recgift.anchorId.."_month",recgift.send_user_code)
    if not giftmonth then

    	local ok, err = red:hmset("giftrank_value_"..recgift.anchorId.."_month",recgift.send_user_code,cjson.encode(recgift))
    	if not ok then  
    		ngx.log(ngx.ERR,"giftmonth insert err",err)
    	end

    else
    		 --获取原周礼物数据
    		 local resultmonth = cjson.decode(giftmonth[1])
                if not resultmonth then
                    local ok, err = red:hmset("giftrank_value_"..recgift.anchorId.."_month",recgift.send_user_code,cjson.encode(recgift))
                        if not ok then  
                            ngx.log(ngx.ERR,"giftmonth insert err",err)
                        end
                 else
                     local pre_month_gift_total_value = resultmonth["gift_total_value"]; 

                     local new_month_gift_total_value = recgift["gift_total_value"]; 
                    --进行累计
                     local total_month_gift_value = tonumber(pre_month_gift_total_value)+tonumber(new_month_gift_total_value)

                     resultmonth["gift_total_value"] = total_month_gift_value
                        resultmonth["nickname"] = recgift["nickname"]
                     --再存储
                     local ok,err = red:hmset("giftrank_value_"..recgift.anchorId.."_month",recgift.send_user_code,cjson.encode(resultmonth))
                        if not ok then  
                         ngx.log(ngx.ERR,"giftmonth insert err",err)
                    end

                end    
    		
    	end	

    --总榜相关处理
    local gifttotal = red:hmget("giftrank_value_"..recgift.anchorId.."_total",recgift.send_user_code)
    if not gifttotal then

    	local ok, err = red:hmset("giftrank_value_"..recgift.anchorId.."_total",recgift.send_user_code,cjson.encode(recgift))
    	if not ok then  
    		ngx.log(ngx.ERR,"gifttotal insert err",err)
    	end

    else
    		 --获取原周礼物数据
    		 local resulttotal = cjson.decode(gifttotal[1])

             if not resulttotal then

                local ok, err = red:hmset("giftrank_value_"..recgift.anchorId.."_total",recgift.send_user_code,cjson.encode(recgift))
                if not ok then  
                 ngx.log(ngx.ERR,"gifttotal insert err",err)
                end
             else
             
                local pre_total_gift_total_value = resulttotal["gift_total_value"]; 

                 local new_total_gift_total_value = recgift["gift_total_value"]; 
                --进行累计
                local total_total_gift_value = tonumber(pre_total_gift_total_value)+tonumber(new_total_gift_total_value)

                resulttotal["gift_total_value"] = total_total_gift_value
                resulttotal["nickname"] = recgift["nickname"]
                --再存储
                local ok,err = red:hmset("giftrank_value_"..recgift.anchorId.."_total",recgift.send_user_code,cjson.encode(resulttotal))
                if not ok then  
                 ngx.log(ngx.ERR,"gifttotal insert err",err)
             end

             end   

    		 
    	end	
    	
    	
    end


    --[[主播收到各种礼物的数量]]
    local function  anchorReceiveGiftsNum (recgift)
	--判空
	local red = redis:new()
	--周榜相关处理
	local giftweek = red:hmget("giftrank_num_"..recgift.anchorId.."_week",recgift.gift_type_id_fk)
	if not giftweek then

		local ok, err = red:hmset("giftrank_num_"..recgift.anchorId.."_week",recgift.gift_type_id_fk,cjson.encode(recgift))
		if not ok then  
			ngx.log(ngx.ERR,"giftweeknum insert err",err)
		end

	else
    		 --获取原周礼物数据
    		 local resultweek = cjson.decode(giftweek[1])
             if not resultweek then

                local ok, err = red:hmset("giftrank_num_"..recgift.anchorId.."_week",recgift.gift_type_id_fk,cjson.encode(recgift))
                    if not ok then  
                     ngx.log(ngx.ERR,"giftweeknum insert err",err)
                end
             else
                 local pre_week_gift_num = resultweek["gift_number"]; 

                 local new_week_gift_num = recgift["gift_number"]; 
                 --进行累计
                 local total_week_gift_num = tonumber(pre_week_gift_num)+tonumber(new_week_gift_num)

                 resultweek["gift_total_value"] = tonumber(total_week_gift_num)*tonumber(recgift.gift_value)
                 resultweek["gift_number"] = total_week_gift_num
                 if recgift["gift_name"] then
                   resultweek["gift_name"] = recgift["gift_name"]
                    end
                 --再存储
                  local ok,err = red:hmset("giftrank_num_"..recgift.anchorId.."_week",recgift.gift_type_id_fk,cjson.encode(resultweek))
                   if not ok then  
                     ngx.log(ngx.ERR,"giftweeknum insert err",err)
                    end
             end   
    		
    	end	

    --月榜相关处理
    local giftmonth = red:hmget("giftrank_num_"..recgift.anchorId.."_month",recgift.gift_type_id_fk)
    if not giftmonth then

    	local ok,err = red:hmset("giftrank_num_"..recgift.anchorId.."_month",recgift.gift_type_id_fk,cjson.encode(recgift))
    	if not ok then  
    		ngx.log(ngx.ERR,"giftmonthnum insert err",err)
    	end

    else
    		 --获取原周礼物数据
    		 local resultmonth = cjson.decode(giftmonth[1])
              if not resultmonth then
                local ok,err = red:hmset("giftrank_num_"..recgift.anchorId.."_month",recgift.gift_type_id_fk,cjson.encode(recgift))
                 if not ok then  
                    ngx.log(ngx.ERR,"giftmonthnum insert err",err)
                 end

              else 
                local pre_month_gift_num = resultmonth["gift_number"]; 

                local new_month_gift_num = recgift["gift_number"]; 
                 --进行累计
                local total_month_gift_num = tonumber(pre_month_gift_num)+tonumber(new_month_gift_num)
                resultmonth["gift_total_value"] = tonumber(total_month_gift_num)*tonumber(recgift.gift_value)
                resultmonth["gift_number"] = total_month_gift_num
                 if recgift["gift_name"] then
                     resultmonth["gift_name"] = recgift["gift_name"]
                 end
                --再存储
                local ok,err = red:hmset("giftrank_num_"..recgift.anchorId.."_month",recgift.gift_type_id_fk,cjson.encode(resultmonth))
                if not ok then  
                     ngx.log(ngx.ERR,"giftmonthnum insert err",err)
                end

             end 
    		 
    	end	

    --日榜相关处理
    local gifttotal = red:hmget("giftrank_num_"..recgift.anchorId.."_day",recgift.gift_type_id_fk)
    if not gifttotal then

    	local ok, err = red:hmset("giftrank_num_"..recgift.anchorId.."_day",recgift.gift_type_id_fk,cjson.encode(recgift))
    	if not ok then  
    		ngx.log(ngx.ERR,"giftweeknum insert err",err)
    	end

    else
    		 --获取原周礼物数据
    		 local resulttotal = cjson.decode(gifttotal[1])
             if  not resulttotal  then
                local ok, err = red:hmset("giftrank_num_"..recgift.anchorId.."_day",recgift.gift_type_id_fk,cjson.encode(recgift))
                 if not ok then  
                    ngx.log(ngx.ERR,"giftweeknum insert err",err)
                 end
             else
              
               local pre_total_gift_num = resulttotal["gift_number"]; 

               local new_total_gift_num = recgift["gift_number"]; 
               --进行累计
               local total_total_gift_num = tonumber(pre_total_gift_num)+tonumber(new_total_gift_num)
                resulttotal["gift_total_value"] = tonumber(total_total_gift_num)*tonumber(recgift.gift_value)
                resulttotal["gift_number"] = total_total_gift_num
                if recgift["gift_name"] then
                 resulttotal["gift_name"] = recgift["gift_name"]
                end
                --再存储
                local ok,err = red:hmset("giftrank_num_"..recgift.anchorId.."_day",recgift.gift_type_id_fk,cjson.encode(resulttotal))
                if not ok then  
                  ngx.log(ngx.ERR,"gifttotalnum insert err",err)
                end

             end  
    		 
    	end	

    end

local red = redis:new()
--修改值
local currentBalance = 0
local balance ,err = red:get("balance_"..gift_record.send_user_code)
  if balance then
     currentBalance = tonumber(balance) - tonumber((tonumber(args.gift_number))*(tonumber(args.gift_value)))

    if currentBalance > 0 then

       local res ,err = red:set("balance_"..gift_record.send_user_code,currentBalance)
        if not res then
             local  result = responeData.new_failed({},err)
             ngx.say(cjson.encode(result))
            return
        end 
    else
        local  result = responeData.new_failed({},"balance is not enough")
            ngx.say(cjson.encode(result))
        return
    end

 else

    local  result = responeData.new_failed({},err)

    ngx.say(cjson.encode(result))
    return
end

 anchorReceiveGiftsValue(gift_rank_value)
 anchorReceiveGiftsNum(gift_rank_num)

 local daysec = getSecDistancToNextday()
 local weekSec =  getSecDistancToNextWednesday()
 local monthSec =  getSecDistancToNextMonthFirstDay()

 --周榜超时相关处理
 red:expire("giftrank_value_"..args.rec_user_code.."_week",weekSec)

 red:expire("giftrank_value_"..args.rec_user_code.."_month",monthSec)
 red:expire("giftrank_num_"..args.rec_user_code.."_day",daysec)
 red:expire("giftrank_num_"..args.rec_user_code.."_week",weekSec)
 red:expire("giftrank_num_"..args.rec_user_code.."_month",monthSec)


local accountparocess = {}
accountparocess.anchor_user_code = args.rec_user_code
accountparocess.user_code = args.send_user_code
accountparocess.variable  = (tonumber(args.gift_number))*(tonumber(args.gift_value))
accountparocess.balance = currentBalance
--0减少1增加
accountparocess.increase = 0
--1送礼2押注
accountparocess.consume = 1




gift_record.statemented = 1
local dbres,err = multiDbOp.sendGiftOperation(gift_record,accountparocess)
if not dbres then 

   local failBalance = tonumber(currentBalance) + (tonumber(args.gift_number))*(tonumber(args.gift_value))
   local res ,err = red:set("balance_"..gift_record.send_user_code,failBalance)
    local reponse = {}
    reponse.balance  = failBalance
    local  result = responeData.new_failed(reponse)
	ngx.say(cjson.encode(result))
	return 
end

local user = {}

user.user_code_fk = args.rec_user_code

local baseDbOp = baseDb.new()

local baseDbres,baseDberr = baseDbOp.getBaseFromSql("select * from t_account",user,"and")

if baseDbres then

    local reslength = table.getn(baseDbres)
        --判断是否查询到结果
    if reslength > 0 then

     local mapuser = baseDbres[1]

     local anchorBalance = mapuser["balance"]

     if not anchorBalance then

        anchorBalance = 0

     end   

     local anchorCurrentBalance = tonumber(anchorBalance)+(tonumber(args.gift_number))*(tonumber(args.gift_value))


     local insertAnchor = {}

      insertAnchor.balance = anchorCurrentBalance 


     baseDbres,baseDberr =  baseDbOp.updateBaseFromSql("t_account",insertAnchor,user)

     if not baseDbres then

            ngx.log(ngx.ERR,"update anchorBalance err",baseDberr)

     end   


    end 
end    





local reponse = {}
reponse.balance  = currentBalance
local  result = responeData.new_success(reponse)
ngx.say(cjson.encode(result))
