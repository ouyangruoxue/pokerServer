
--[[

 	牌桌公共默认信息

--]]
local _M = {
	playerlist={}, --玩家集合
	playernum = 0, --玩家数量大于二的时候并且玩家状态为进行中的时候开始
	chiPool = 0, --筹码底池
	tableStatus =  0, --初始化状态牌桌状态
	bettingRound = 0, --发牌状态
	tablecards = {}  --每局共用的5张扑克牌  
}


local BettingRounds = {
		not_start = 0,		--底分扣除阶段
        Pre_flop = 1,       --底牌权 / 前翻牌圈 - 公共牌出现以前的第一轮叫注。
        Flop_round = 2,     --翻牌圈 - 首三张公共牌出现以后的押注圈 。
        Turn_round = 3,     --转牌圈 - 第四张公共牌出现以后的押注圈 。
        River_round =4     --河牌圈 - 第五张公共牌出现以后 , 也即是摊牌以前的押注圈 。
}


local tableStatus = {
    Offine = 0 ,        --未开始
    Playing = 1,        --进行中
    over = 2           --结束状态 
    
}


_M._VERSION = '0.01'
        
local mt = { __index = _M }                    

function _M.new()
    return setmetatable({}, mt)    
end


return _M