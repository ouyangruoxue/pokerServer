--[[
-- 扑克牌的数据预定义
-- 提供扑克牌的生成,随机输出牌,
-- 同时修改该扑克牌的状态防止系统被攻击或者串改
]]--

--[[
花色：suit
红心：hearts
梅花：clubs (也叫 clovers)
方块：diamonds
黑桃：spades
例如“跟出同一花色的牌”叫 follow suit
将牌(王牌,主)花色叫 trump suit
红心3叫 three of hearts
-- 花色定义
"spades","hearts","clubs",'diamonds'
--]]
PokerSuitType = {
    Spades = 4,
    Hears = 3,
    Clubs = 2,
    diamons = 1, 
}
--[[
    牌ID 定义
    扑克牌中红桃（红心）、黑桃、方块（方片）及梅花（草花）分别用英语hearts、spades、diamonds及clubs表示。记住一定用复数。 
    A读作ACE 复数是ACES 
    2-9用正常数字读法 JQK分别读作Jack Queen King 
    王为JOKER 
    读完整扑克牌名时英语习惯先说数值后说花色，恰与中文相反 
--]]
PokerCardID = {
            RedJoker    = 16,
            BlackJoker  = 15,
            Ace         = 14,
            King        = 13,
            Queen       = 12,
            Jack        = 11,
            Ten         = 10,
            Nine        = 9,
            Eight       = 8,
            Seven       = 7,
            Six         = 6,
            Five        = 5,
            Four        = 4,
            Three       = 3,
            Two         = 2, 
}

PokerCard = {
    CardId = PokerCardID.RedJoker;
    Suit = PokerSuitType.Hears;
    IsUsed = 1; -- 0表示已经使用 1表示未使用
}

local Poker = {};

-- 初始化扑克
function Poker.new(number)
-- 根据需要初始化的扑扑克返回扑克
    for i = 1,number,1 do 

    end
end

 