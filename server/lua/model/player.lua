local _M = {
	playerName = "玩家1",--玩家昵称
	playerIcon = "玩家头像", --玩家头像
	playChip = 100 ,--玩家总筹码数
	betAmount = 0,  --玩家下注金额 
	playStatus =  2, --初始化状态一进去都为观望状态
	playerAction = 1, --玩家当前操作
	cards = {}  --玩家专属的2张扑克牌  
}


local playerActions = { 
    Bet     = 1,        --押注 - 押上筹码
    Call    = 2,       --跟进 - 跟随众人押上同等的注额
    Fold    = 3,       --收牌 / 不跟 - 放弃继续牌局的机会
    Check   = 4,       --让牌 - 在无需跟进的情况下选择把决定“让”给下一位
    Raise   = 5,       --加注 - 把现有的注金抬高
    ReRaise = 6,       --再加注 - 再别人加注以后回过来再加注
    AllIn   = 7       --全押 - 一次过把手上的筹码全押上 
}


local playerStatus = {
    Offine = 0 ,        --掉线/离线
    Playing = 1,        --正常进行
    Watch = 2,          --观望 
    Bust = 3,           --出局   
}

_M._VERSION = '0.01'
        
local mt = { __index = _M }                    

function _M.new()
    return setmetatable({}, mt)    
end


return _M