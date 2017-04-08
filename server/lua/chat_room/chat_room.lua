--[[
-- chatroom/chatroom.lua
-- 聊天室模块创建，用来存储系统用户的聊天室信号量等信息
-- 聊天室管理类,用于系统关于聊天室相关的操作
-- 支持多对多频道 
-- 支持 websocket
--
-- Author: Steven.com <zhangliutong@zhengsutec.com> 
-- 2017.03.12
--]]
 
local _CHATROOM_ERR = require "chat_room.chat_room_err" 
local redis_lock = require "common.redis_lock"
require "init.lua_func_ex"
local Player =  require "game.TexasHoldem.Player"
local CardSet = require "game.TexasHoldem.CardSet"
local _TexasHoldem = require "game.TexasHoldem.TexasHoldem"
local _NNPoker = require "game.niuniu.niuniu";
local randomname = require "game.TexasHoldem.player_robot_name"
local Card = require "game.TexasHoldem.Card"
local redis = require "redis.zs_redis"
local cjson = require "cjson"
local uuid = require 'resty.jit-uuid'
local betdb = require "db.bet.bet_db"




local _Chatroom = {
	roomId = "",
	roomName = "",
	anchor_user_code = "",
	playerUpLimit = 100,
	playerS = 0,
	roomPwd = "",
	--游戏类型1德州扑克2牛牛
	game_type = 1,
	--房间类型
    room_type = 0,
	roomSamp = nil,
	--直播状态 1表示直播 0表示未开播
	anchor_status = 0,
	--玩家map
	gamePlayMap={},
	--房间所有人
	playerMap = {},
	--押注输赢map
	stakeMap = {},
    --单次押注排行
    betRank = {},

	stakePokeTypeMap={},

	room_status = 0,
	
	gameSatus = 0,

	--公共牌
	publicCards = {},

    --押注总金额
    total_bet = {},
    --限红
    limit_red = {},


    anchorNeteaseRoomId = "",--云信聊天室id

    -- 扑克牌
    poker = { },

    --赢家
    winer = nil,

	lock = nil
}


local gameSatus = {


    -- 等待开始
    WAITTING = 1,

    -- 等待下注
    READY = 2,
    
    -- 停止下注 

    WaitBet = 3 ,

    -- 发牌
    PLAYING = 4,

    -- 开牌
    TURN_ON = 5,

    --结算
    settlement = 6

}


_Chatroom.__index = _Chatroom; 


--[[
-- join 加入房间的函数,携带用户id,用户的信号量,系统判断该用户id是否存在,
-- 如果存在则关闭之前的对象,由于系统中主播会携带多个聊天室,所以主播
-- example
     

-- @param _self 对象本身,使用:则隐式调用
-- @param userId 玩家id
-- @param semp 玩家信号量
-- @param pwd  密码
-- @param 返回房间对象
]]


_Chatroom.join = function (_self, userId, semp, roomPwd )
	
	if tonumber(_self.room_type) == 1 then
	if roomPwd ~= _self.roomPwd then
		-- 密码不正确
		return _CHATROOM_ERR.ERR_ROOM_PWD_ERROR
		end
	end
	-- local playerS = _self.playerS; 
	-- if playerS + 1 > _self.playerUpLimit then
	-- 	return _CHATROOM_ERR.ERR_CHATROOM_FULLED
	-- end
    local userId = tostring(userId)
	-- 添加用户进入房间 -- 如果用户已经存在
	if _self.playerMap[userId] then
		local semp = _self.playerMap[userId].userSemp;
		if semp then
			-- 发送事件 通知系统关闭semp 断开socket连接
			semp:post(1);
		end
		------- 将该用户从全局 websocket map集合中删除 
		-- 
	end

	_self.playerMap[userId] = {
		userSemp = semp, 
	};
	-- ngx.log(ngx.ERR,"joined the room userId is ",userId," ")
	_self.playerS = _self.playerS + 1
	return _CHATROOM_ERR.ERR_OK;
end

--[[
-- 发送消息api,用于各种消息的管理和处理
-- 
-- example	
]]

_Chatroom.sendMsg = function(_self,msg)
	 
	-- 聊天室 共享内存,用于lock 
	local lock = _self.lock;
	if not lock then  
		ngx.log(ngx.ERR,"join anchor room error ,the lock is nil")
		return nil
	end
	-- 访问房间锁
 	local elapsed, err = lock:lock("Message".._self.anchor_user_code) 
 	if not elapsed then 
    	 ngx.log(ngx.ERR,"failed to acquire the lock", err)
    	 return nil
	end
	
	local playersMap = _self.playerMap
	-- 测试代码 用于发送消息的分发
	-- msg 

	local chat_room = ngx.shared.chat_room
	local succ, err, forcible = chat_room:set("Message".._self.anchor_user_code, msg)
 			 
	for k,v in pairs(playersMap) do
		local player = v;
		local _sema = player.userSemp;
		if _sema then
			_sema:post(1)
		end
	end

	-- 释放房间锁
    local ok, err = lock:unlock()
    if not ok then
        ngx.log(ngx.ERR,"failed to unlock: ", err)
        return nil
	end
end


function _Chatroom:sendMsgToNetease()

    local http = require "resty.http"
    local neteaseHead =  require "netease.netease_header"
    local httpc = http:new()


    ngx.update_time()

    local tSec = ngx.now()
    uuid.seed(tSec)
    local msgid = uuid()

    local ext = {}

    ext.betRank = self.betRank

    ext.onlineNum = self.playerS

    local headr = neteaseHead.getNeteaseHttpHeadr(0)
    
    if not self.anchor_user_code or not self.anchorNeteaseRoomId then
        return false
    end    


    local caputureAgrs = {}
    caputureAgrs.fromAccid = self.anchor_user_code
    caputureAgrs.roomid = self.anchorNeteaseRoomId
    caputureAgrs.msgType = 100
    caputureAgrs.msgId = msgid
    caputureAgrs.attach = cjson.encode(ext)

   local res, err = httpc:request_uri("https://api.netease.im/nimserver/chatroom/sendMsg.action",{
        method = "POST",
        body = ngx.encode_args(caputureAgrs),
        ssl_verify = false, -- 需要关闭这项才能发起https请求
        headers = headr,
      })

    if not res then
         ngx.log(ngx.ERR, "555555555555555555555555555555",err)
        return false
    end
    
    local captureTab = cjson.decode(res.body)
    if tonumber(captureTab.code) ~= 200 then
        return false
    end 

    return true

end



--[[
   --玩家下注排行相关操作
  --@parm Message 下注内容
--]]
 
local function compare(x, y) --从大到小排序
      return x.stake > y.stake         --如果第一个参数大于第二个就返回true，否则返回false
   end

--[[
  --玩家下注
  --@parm gameplayerId 下注对象
  --@parm Message 下注内容
  --@parm stake_type 下注类型1输赢2牌型
--]]
 function  _Chatroom:bet (Message)
	--判断如果不存在牌局玩家对应的下注table就新建一个
	--判空
    --判断所选玩家编号
	if  not Message.game_record_vplayer then 
		return _CHATROOM_ERR.ERR_USER_CODE_ERROR
	end 

    if self.gameSatus > 2 then 
        return _CHATROOM_ERR.ERR_GAME_BET_TIME_OUT
    end 

    local  gameplayerId = tostring(Message.game_record_vplayer)
	if tonumber(Message.stake_type) == 1 then

	
	--判空
 	  if not self.stakeMap[gameplayerId] then
 		 self.stakeMap[gameplayerId] = {}
 	  end	

 	  local  stakeGameMap = self.stakeMap[gameplayerId]

        local user_code = Message.stake_user_code
 	  if  not user_code  then
 		 return _CHATROOM_ERR.ERR_USER_CODE_ERROR
 	  end	
 	--判断是否已经下注，未下注过直接插入,下注过的更新金额
    	table.insert(stakeGameMap,Message)
         local stake_win_or_lose = Message.stake_win_or_lose
        ngx.log(ngx.ERR,"stake_win_or_lose",cjson.encode(Message))
       if not self.total_bet[tostring(gameplayerId)] then

            self.total_bet[tostring(gameplayerId)] = {}
            self.total_bet[tostring(gameplayerId)][tostring(stake_win_or_lose)] = tonumber(Message.stake)
        else
           
            if not self.total_bet[tostring(gameplayerId)][tostring(stake_win_or_lose)] then

                self.total_bet[tostring(gameplayerId)][tostring(stake_win_or_lose)] = tonumber(Message.stake)

             else
                local preStakewinOrlose = self.total_bet[tostring(gameplayerId)].stake_win_or_lose

                self.total_bet[tostring(gameplayerId)][tostring(stake_win_or_lose)] = tonumber(Message.stake)+tonumber(preStakewinOrlose)

             end   

       end 

        local statustable = {}
        statustable.type = 4
        --1总下注金额2限红
        statustable.bet_type = 1
        statustable.data = self.total_bet
        local msgJson = cjson.encode(statustable)
        self:sendMsg(msgJson)

  else 

	--判空
 	  if not self.stakePokeTypeMap[gameplayerId] then
 		 self.stakePokeTypeMap[gameplayerId] = {}		
 	  end	

 	--判断所压牌型的table在不在 不在就新建
 	  local poker_type = Message["poker_type"]
 	  if not self.stakePokeTypeMap[gameplayerId][poker_type] then
 		 self.stakePokeTypeMap[gameplayerId] = {}
 	  end	


 	  local stakeTypeMap = self.stakePokeTypeMap[gameplayerId]

        local user_code = Message.stake_user_code
 	
 	  if  not user_code  then
 		 return _CHATROOM_ERR.ERR_USER_CODE_ERROR
 	  end	
 	--直接插入,保存多条记录
       
    	   table.insert(stakeTypeMap,Message)
    
	end	

    ---押注前三排行
    if table.getn(self.betRank) < 3 then

         table.insert(self.betRank,Message)
         table.sort(self.betRank,compare)

     else

        local isbigBet = false
        for i=1,table.getn(self.betRank) do
            
            local  tempBet = self.betRank[i]

            if tonumber(tempBet["stake"]) < tonumber(Message["stake"]) then
                table.remove(self.betRank,i)
                isbigBet = true
                break
            end    

        end
        
        if isbigBet then
            table.insert(self.betRank,Message)
            table.sort(self.betRank,compare)  
         end    
     end 



	return _CHATROOM_ERR.ERR_OK;
end

--[[
--对押注人员进行针对性的牌局消息发送
--@parm gameplayId 牌局玩家id
--@parm msg 消息（所属牌局玩家牌消息）
--]]
 function _Chatroom:sendMsgForBetResult()
     
    -- 聊天室 共享内存,用于lock 
    local lock = self.lock;
    if not lock then  
        ngx.log(ngx.ERR,"join anchor room error ,the lock is nil")
        return nil
    end

    -- 访问房间锁
      --输赢的消息回发
     for i=2,table.getn(self.gamePlayMap),1 do
        local playerrobot = self.gamePlayMap[i]
        local gameplayid = tostring(playerrobot.game_player_id)
        local stakeTempMap = self.stakeMap[gameplayid]
        
        if stakeTempMap then
         for i=1,table.getn(stakeTempMap) do
             local staketemp = stakeTempMap[i]
             local userId = tostring(staketemp.stake_user_code)  
             local chat_room = ngx.shared.chat_room
            --拼装返回的押注消息
             local  returnBet = {}
              returnBet.type = 5
              returnBet.data = staketemp

             local elapsed, err = lock:lock("Message"..self.anchor_user_code) 
                if not elapsed then 
                  ngx.log(ngx.ERR,"failed to acquire the lock", err)
                  return nil
                 end


                local succ, err, forcible = chat_room:set("Message"..self.anchor_user_code, cjson.encode(returnBet))
                if self.playerMap[userId] then

                     local _semp = self.playerMap[userId].userSemp; 
                     if _semp then
                        _semp:post(1)
                     end 
                end
                -- -- 释放房间锁
                local ok, err = lock:unlock()
                if not ok then
                     ngx.log(ngx.ERR,"failed to unlock: ", err)
                 return nil
                end
            end
        end
    end

    --押注类型的消息回发

    local theblanker = self.gamePlayMap[1]
    local stakeTypeTempMap = self.stakePokeTypeMap[tostring(theblanker.game_player_id)]
    if stakeTypeTempMap then
        for i=1,table.getn(stakeTypeTempMap) do
            local staketypepeople = stakeTypeTempMap[i]
            local userId = tostring(staketypepeople.stake_user_code) 
            local chat_room = ngx.shared.chat_room
                --拼装返回的押注消息
                local  returnBet = {}
                 returnBet.type = 5
                returnBet.data = staketypepeople

                 local elapsed, err = lock:lock("Message"..self.anchor_user_code) 
                if not elapsed then 
                  ngx.log(ngx.ERR,"failed to acquire the lock", err)
                  return nil
                 end

                local succ, err, forcible = chat_room:set("Message"..self.anchor_user_code, cjson.encode(returnBet))
                local _semp = self.playerMap[userId].userSemp; 
                if _semp then
                    _semp:post(1)
                end   

                 -- 释放房间锁
                 local ok, err = lock:unlock()
                if not ok then
                     ngx.log(ngx.ERR,"failed to unlock: ", err)
                 return nil
                end 

        end    
    end 
    return true

end

--初始化牌局状态
_Chatroom.prepare = function (premature,_self)
    _self.publicCards = CardSet:new()
    _self.poker = CardSet:new()
    _self.stakeMap = {}
    _self.stakePokeTypeMap = {}
    _self.betRank = {}
    _self.total_bet = {}


    for suit = 1, 4, 1 do
        for id = 1, 13, 1 do
            _self.poker[id + 13 *(suit - 1)] = Card:new(suit, id + 1)
        end
    end
    for i = 1,table.getn(_self.gamePlayMap),1 do
    	local gamePlayTempMap = _self.gamePlayMap[i]
    	gamePlayTempMap.handCards = CardSet:new()
    	gamePlayTempMap.cards = CardSet:new()
    end	
    	

    local statustable = {}
    statustable.type = 8
    statustable.data = {}
    statustable.data.playerList = _self.gamePlayMap
    statustable.data.publicCards = _self.publicCards
    statustable.data.gameSatus = 1
    _self.gameSatus = 1
    local msgJson = cjson.encode(statustable)
    _self:sendMsg(msgJson)
   
    --5
    local ok, err = ngx.timer.at(5, _self.startBet,_self)
     if not ok then
         ngx.log(ngx.ERR, "failed to create timer: ", err)
         return
     end
end

_Chatroom.startBet = function (premature ,_self)
	local statustable = {}
    statustable.type = 8
    statustable.data = {}
    statustable.data.playerList = _self.gamePlayMap
    statustable.data.publicCards = _self.publicCards
    statustable.data.gameSatus = 2
    _self.gameSatus = 2
    local msgJson = cjson.encode(statustable)
    _self:sendMsg(msgJson)
    --18
    local ok, err = ngx.timer.at(18, _self.stopBet,_self)
     if not ok then
         ngx.log(ngx.ERR, "failed to create timer: ", err)
         return
     end
end


_Chatroom.stopBet = function (premature ,_self)
	local statustable = {}
    statustable.type = 8
    statustable.data = {}
    statustable.data.playerList = _self.gamePlayMap
    statustable.data.publicCards = _self.publicCards
    statustable.data.gameSatus = 3
    _self.gameSatus = 3
    local msgJson = cjson.encode(statustable)
    _self:sendMsg(msgJson)
    _self:sendMsgToNetease()
    -- local thread1 = ngx.thread.spawn()  --开启第一个线程； 第一个参数是匿名函数 后面的参数是匿名函数的参数

    -- ngx.thread.wait(thread1)  --等待第一个线程的返回结果  


    --5
    local ok, err = ngx.timer.at(5, _self.dealCardByGameType,_self)
     if not ok then
         ngx.log(ngx.ERR, "failed to create timer: ", err)
         return
     end
end



--[[
-- 根据游戏类型发不同的牌
 --@parm gameType 游戏类型
--]]
_Chatroom.dealCardByGameType = function (premature ,_self)

	if tonumber(_self.game_type) == 1 then

     _self:dealHandCard(2)
     _self:dealPublicCard(5)
     -- ngx.log(ngx.ERR, "myuser_code--------------: ", cjson.encode(_self.anchor_user_code))
     -- ngx.log(ngx.ERR, "myhandcards-----------: ", cjson.encode(_self.gamePlayMap))
     -- ngx.log(ngx.ERR, "mypubliccards-----------: ", cjson.encode(_self.publicCards))	

    elseif tonumber(_self.game_type) == 2 then
    	_self:dealHandCard(5)

    else	
    
    end		

    local statustable = {}
    statustable.type = 8
    statustable.data = {}
    statustable.data.playerList = _self.gamePlayMap
    statustable.data.publicCards = _self.publicCards
    statustable.data.gameSatus = 4
    _self.gameSatus = 4
    local msgJson = cjson.encode(statustable)
    _self:sendMsg(msgJson)
    --9
     local ok, err = ngx.timer.at(9, _self.turnon,_self)
     if not ok then
         ngx.log(ngx.ERR, "failed to create timer: ", err)
         return
     end
end


--[[
-- 开牌
--根据游戏类型1德州扑克2牛牛
-- 结算牌局大小情况
 --
--]]
_Chatroom.turnon  = function (premature ,_self)

    if tonumber(_self.game_type) == 1 then

    	for i = 1, table.getn(_self.gamePlayMap), 1 do
        	_self.gamePlayMap[i].cards, _self.gamePlayMap[i].cardype = _TexasHoldem.getUsersMaxCards(_self.gamePlayMap[i].handCards, _self.publicCards);
   		end
   		-- 比牌
   		for i=2,table.getn(_self.gamePlayMap),1 do
   			local playmaster = _self.gamePlayMap[1]
   			local playerrobot = _self.gamePlayMap[i]
   			local playerwin = _TexasHoldem.JugePlayerCards(playmaster,playerrobot)
   			if playerwin.game_player_id == playerrobot.game_player_id then
   				_self.gamePlayMap[i].game_result = 1
   			else
   				_self.gamePlayMap[i].game_result = 0
   			end

   		end
    	

    elseif tonumber(_self.game_type) == 2 then
    		
    	for i = 1, table.getn(_self.gamePlayMap), 1 do
        	_self.gamePlayMap[i].cardType, _self.gamePlayMap[i].cards = _NNPoker.getCardsMaxType(_self.gamePlayMap[i].handCards)
   		end

   		-- 比牌
   		for i=2,table.getn(_self.gamePlayMap),1 do
   			local playmaster = _self.gamePlayMap[1]
   			local playerrobot = _self.gamePlayMap[i]

   			local isPlayer1 = _NNPoker.jugeCards(playmaster.handCards, playerrobot.handCards)
   			if isPlayer1 then
   				_self.gamePlayMap[i].game_result = 0
   			else
   				_self.gamePlayMap[i].game_result = 1
   			end

   		end

    else	
    
    end		

    



    local statustable = {}
    statustable.type = 8
    statustable.data = {}
    statustable.data.playerList = _self.gamePlayMap
    statustable.data.publicCards = _self.publicCards
    statustable.data.gameSatus = 5
    _self.gameSatus = 5
    local msgJson = cjson.encode(statustable)
    _self:sendMsg(msgJson)


    

     local ok, err = ngx.timer.at(6, _self.settlement,_self)
     if not ok then
         ngx.log(ngx.ERR, "failed to create timer: ", err)
         return
     end
end


--[[
-- 开牌
--根据游戏类型1德州扑克2牛牛
-- 结算牌局大小情况
 --
--]]
_Chatroom.settlement  = function (premature ,_self)

   local result = true
   local returnBetResult = true

    local index = 0
    for k,v in pairs(_self.stakeMap) do
        if k then
            index = 1;
            break
        end    
    end
    local typeindex = 0
    for k,v in pairs(_self.stakePokeTypeMap) do
        if k then
            typeindex = 1;
            break
        end    
    end

    if index > 0 or typeindex > 0 then
        
     --下注结果处理 数据库更新
     result = _self:resulthandle()
  
    --下注消息回发
     returnBetResult = _self:sendMsgForBetResult()
    
    end    

     if tonumber(anchor_status) == 0 or tonumber(room_status) == 0 then
         return
     end 

     if result and returnBetResult then
        --6
        local ok, err = ngx.timer.at(3, _self.prepare,_self)
        if not ok then
         ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
     end

    end     

end


--[[ 
    结果处理数据redis更新
--]]
function _Chatroom:resulthandle()
 
    local betdbOp =  betdb.new()

    local record_id_fk = redis_lock.generateUniqueUserCode("wj_game_game_record_id",1)

    for i,v in ipairs(self.gamePlayMap) do
        local tempPlayMap = v
        v.game_record_id_fk = record_id_fk
    end


    local game_record = {}
    game_record.game_room_id_fk = self.roomId
    game_record.game_record_id_fk = record_id_fk
    game_record.game_type = self.game_type
    game_record.game_info = cjson.encode(self.gamePlayMap)
    --更新牌局记录
    local gameRecordres,gameRecordreserr =  betdbOp.insertNewPoker(game_record)
    if not gameRecordres then
        ngx.log(ngx.ERR, "failed to update gamerecord: ", gameRecordreserr)
        return  nil
    end

    --存储玩家牌局以及输赢信息
    local playres,plyerr =  betdbOp.insertNewPokerPlayer(self.gamePlayMap)
    if not playres then
        ngx.log(ngx.ERR, "failed to create gameplayer: ", plyerr)
        return  nil
    end
    --处理输赢结果
    

    local accountparocess = {}
    local red = redis:new()

    --奖金池
    local capital_pool,err = red:get("wj_capital_pool")
    if not capital_pool then
        capital_pool = 0
    end   

    local sqlStakeMap = {}
    for i=2,table.getn(self.gamePlayMap),1 do
        local playerrobot = self.gamePlayMap[i]
        local gameplayid = tostring(playerrobot.game_player_id)
        local stakeTempMap = self.stakeMap[gameplayid]
        if stakeTempMap then
        for i=1,table.getn(stakeTempMap) do
            local accountparocessTemp = {}
           
            local staketemp = stakeTempMap[i]
            staketemp.game_record_id_fk = record_id_fk

            accountparocessTemp.anchor_user_code = self.anchor_user_code
            accountparocessTemp.user_code = staketemp.stake_user_code
            --2押注1送礼
            accountparocessTemp.consume = 2
            
            if tonumber(playerrobot.game_result) == tonumber(staketemp.stake_win_or_lose) then
                staketemp.win_or_lose = 1
                local balance ,err = red:get("balance_"..staketemp.stake_user_code)
                if balance then
                 local currentBalance = tonumber(balance) + tonumber(staketemp.stake)*(tonumber(staketemp.multiple)+1)*0.95
                 accountparocessTemp.variable  = tonumber(staketemp.stake) *(tonumber(staketemp.multiple)+1)
                 accountparocessTemp.balance = currentBalance
                 staketemp.player_account_balance = currentBalance
                --0减少1增加
                 accountparocessTemp.increase = 1
                 local res ,err = red:set("balance_"..staketemp.stake_user_code,currentBalance)
                    if res then
                         staketemp.statemented = 1
                    end    
                 end 
             capital_pool = tonumber(capital_pool) - tonumber(staketemp.stake)*tonumber(staketemp.multiple)*0.95
            else 
                accountparocessTemp.variable  = staketemp.stake
                accountparocessTemp.balance = staketemp.player_account_balance
                accountparocessTemp.increase = 0  
                staketemp.win_or_lose = 0
                staketemp.statemented = 1
                capital_pool = tonumber(capital_pool) + tonumber(staketemp.stake)
            end 
               table.insert(sqlStakeMap,staketemp)
               table.insert(accountparocess,accountparocessTemp)
         end
        end
    end
    --数据库数据
    local sqlStaketype = {}
    local theblanker = self.gamePlayMap[1]
    local theblankerCartype = theblanker.cardType
    local gameplayid =  tostring(theblanker.game_player_id)
    local stakeTypeTempMap = self.stakePokeTypeMap[gameplayid]

    if stakeTypeTempMap then
        for i=1,table.getn(stakeTypeTempMap) do
            local accountparocessTemp = {}
            
            local stakeTypetemp = stakeTypeTempMap[i]
            local poker_type = stakeTypetemp["poker_type"]
            stakeTypetemp.game_record_id_fk = record_id_fk

            accountparocessTemp.anchor_user_code = self.anchor_user_code
            accountparocessTemp.user_code = stakeTypetemp.stake_user_code
            --2押注1送礼
            accountparocessTemp.consume = 2

            if tostring(theblankerCartype) == tostring(poker_type) then
            
                stakeTypetemp.win_or_lose = 1
                local balance ,err = red:get("balance_"..stakeTypetemp.stake_user_code)
                if balance then
                    local currentBalance = tonumber(balance) + tonumber(stakeTypetemp.stake) *(tonumber(stakeTypetemp.multiple)+1)
                    accountparocessTemp.variable  = tonumber(stakeTypetemp.stake) *(tonumber(stakeTypetemp.multiple)+1)
                    accountparocessTemp.balance = currentBalance
                     --0减少1增加
                    accountparocessTemp.increase = 1
                    stakeTypetemp.player_account_balance = currentBalance
                    local res ,err = red:set("balance_"..stakeTypetemp.stake_user_code,currentBalance)
                    if res then
                      staketemp.statemented = 1
                    end 
                    capital_pool = tonumber(capital_pool) - tonumber(staketemp.stake)*tonumber(staketemp.multiple)*0.95   
                end 
              
            else  
            accountparocessTemp.variable  = stakeTypetemp.stake
            accountparocessTemp.balance = stakeTypetemp.player_account_balance
            accountparocessTemp.increase = 0    
            stakeTypetemp.win_or_lose = 0
            stakeTypetemp.statemented = 1
            capital_pool = tonumber(capital_pool) + tonumber(staketemp.stake)
            end 
            table.insert(sqlStaketype,stakeTypetemp)
            table.insert(accountparocess,accountparocessTemp)
        end
    end

     local capital_poolres,capital_poolerr = red:set("wj_capital_pool",capital_pool)
     if not capital_poolres then
        ngx.log(ngx.ERR, "capital_poolres ", capital_poolerr)
     end 


    if table.getn(sqlStakeMap) > 0 then
    --存储下注输赢记录
    local stakeres,stakeerr =  betdbOp.insertPlayerStake(sqlStakeMap,1)
        if not stakeres then
            ngx.log(ngx.ERR, "failed to create stakerecord1: ", stakeerr)
         return  nil
        end
    end
    --存储下注类型记录
    if table.getn(sqlStaketype) > 0 then
         local staketyperes,staketypeerr =  betdbOp.insertPlayerStake(sqlStaketype,2)
         if not staketyperes then
            ngx.log(ngx.ERR, "failed to create stakerecord2: ", staketypeerr)
            return  nil
         end
    end

    --存储下注流水
    if table.getn(accountparocess) > 0 then
         local staketyperes,staketypeerr =  betdbOp.insertPlayerAccountProcess(accountparocess)
         if not staketyperes then
            ngx.log(ngx.ERR, "failed to create accountprocess: ", staketypeerr)
            return  nil
         end
    end


    return true

end


math.randomseed(tostring(os.time()):reverse():sub(1, 7))
function _Chatroom:getCard(seed)
     math.randomseed(os.clock()*10000)
    local index = math.random(1, table.getn(self.poker))
    local card = self.poker[index]
    table.remove(self.poker, index)
    return card
end

--[[
-- 每个玩家发底牌底牌
 --@parm pokernum 几张牌
--]]
function _Chatroom:dealHandCard(pokernum)
    for i = 1, table.getn(self.gamePlayMap), 1 do
       for cardnum=1,pokernum do
       	  local card = self:getCard(cardnum)
       	self.gamePlayMap[i].handCards:insert(card)

       end
    end
end


--[[
-- 每个玩家发公共牌
 --@parm pokernum 几张牌
--]]
function _Chatroom:dealPublicCard(pokernum)
    for cardnum=1,pokernum do
       local card = self:getCard(cardnum)
       local publicCards = self.publicCards:insert(card)
      end 
end


--[[
 --用来删除牌局里面的玩家
 --@parm playerList 牌局玩家列表
 --@parm playerid 牌局玩家id
--]]
function _Chatroom:removeRobotPlayer(playerid)
	--删除对应玩家	
	for i= table.getn(self.gamePlayMap),1,-1 do
		local value = parm[i];
		if type(value) == "table" then
			local id = value["id"]
			if id == playerid then
				table.remove(self.gamePlayMap,i);
				break
			end
		end
	
	end

end

--[[
	--创建机器人玩家
--]]
function _Chatroom:ceateRobotPlayer(seed)               
 --随机姓名与性别
 local firstname = nil
 local lastname = nil 
 local robotname = nil
 local randomsex = math.random(1,2)
 if randomsex == 1 then
 	 firstname = randomname.male_first_name[math.random(1,#randomname.male_first_name)]
 	 lastname = randomname.last_names[math.random(1,#randomname.last_names)]
 	 robotname = firstname.." "..lastname
 	else
 	  firstname = randomname.female_first_name[math.random(1,#randomname.female_first_name)]
 	  lastname = randomname.last_names[math.random(1,#randomname.last_names)]
 	  robotname = firstname.." "..lastname	
 end
 --创建机器人code
 local usercode = redis_lock.generateUniqueUserCode("wj_game_robot_usercode",1)

--创建机器人
 local player =  Player:new(usercode, robotname,randomsex,"", CardSet:new(),1)
 
 return player
	
end




--[[ 
	--创建牌局玩家列表
--]]
function _Chatroom:createGamePlayerList()
	local player = {}
	for i=1,4 do
	 
	 local robot = self:ceateRobotPlayer(i)
	 
	 if i == 1 then
	 	robot.isBanker = 1
	 else
	 	robot.isBanker = 0
	 end
	  player[i] = robot	
	end
	return player
end



function _Chatroom:new(roomId,roomName,anchor_user_code,playerUpLimit,gameType,neteaseRoomId,roomPwd)
	-- body
	local  chatRoom = setmetatable({}, _Chatroom);
	if roomId then chatRoom.roomId = roomId;end
	if roomName then chatRoom.roomName = roomName;end
	if anchor_user_code then chatRoom.anchor_user_code = anchor_user_code;end
	if playerUpLimit then chatRoom.playerUpLimit = playerUpLimit;end

	chatRoom.playerMap = {};
	chatRoom.stakeMap = {}
	chatRoom.gamePlayMap = self:createGamePlayerList()
	if gameType then
		chatRoom.game_type = gameType
	end	

    if  neteaseRoomId then
        chatRoom.anchorNeteaseRoomId = neteaseRoomId
    end    

    if roomPwd then
        chatRoom.roomPwd = roomPwd
    end    

	local resty_lock = require "resty.lock"  
	local lock, err =  resty_lock:new("my_locks");
	if not lock then
        ngx.log(ngx.ERR,"failed to create lock: ", err)
        return anchor,_CHATROOM_ERR.ERR_ANCHOR_CREATE_LOCK
    end
    chatRoom.lock = lock;
	return chatRoom;
end





return _Chatroom