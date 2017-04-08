local cjson = require "cjson"
--[[
-- 扑克牌的数据预定义 默认系统返回一个poker信息,不同游戏继承当前poker结构
-- 提供扑克牌的生成,随机输出牌,
-- 同时修改该扑克牌的状态防止系统被攻击或者串改
]]--
local _Poker = {};
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

_Poker.SuitType = {
    Spades  = 4,
    Hears   = 3,
    Clubs   = 2,
    Diamons = 1, 
}
--[[
    牌ID 定义
    扑克牌中红桃（红心）、黑桃、方块（方片）及梅花（草花）分别用英语hearts、spades、diamonds及clubs表示。记住一定用复数。 
    A读作ACE 复数是ACES 
    2-9用正常数字读法 JQK分别读作Jack Queen King 
    王为JOKER 
    读完整扑克牌名时英语习惯先说数值后说花色，恰与中文相反 
--]]
_Poker.CardIDType = {
            RedJoker    = 15,
            BlackJoker  = 14, 
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
            Ace         = 1,
}
--[[
    单张卡牌的id 与 value之间的映射
]]
_Poker.CardIdKeyMap = {
            "Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight",
            "Nine", "Ten", "Jack", "Queen", "King", "BlackJoker", "RedJoker"
}
--[[
    定义扑克牌的单张牌的大小
]]
_Poker.CardValues = {
            RedJoker    = 18,
            BlackJoker  = 17, 
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
            Ace         = 1,
}
--[[
    定义扑克牌的大小
]]
_Poker.CardsEqualResult = {
    Less = -1,
    Equal = 0,
    Greater = 1,
}

--[[


_Poker.PokerCard = {
    cardId = CardID.RedJoker;
    cardSuit = SuitType.Hears;
    isUsed = 1; -- 0表示已经使用 1表示未使用
}
]]
 
 
--[[
-- C_M_N 集合数据样本取法
-- example
    local testSrc3 = {
        1,2,3,4,5
    }
    local resultT3 = C_M_N(testSrc1,3);
    ngx.say("size is "..table.getn(resultT3).." "..cjson.encode(resultT3))

-- @param srcTable 样本集合
-- @param n 样本中需要取出的大小
返回已经结果数组

]]
function  _Poker.C_M_3( srcTable)
    -- body
    local m = table.getn(srcTable);
    local n = 3;
    local index = 1;
    local tDes = {};
    for index1 = 1, m-n+1 , 1 do
        for index2 = index1 + 1, m-1, 1 do
            for index3 = index2 + 1, m, 1 do
                tDes[index] = {
                    srcTable[index1],srcTable[index2],srcTable[index3]
                }
                index = index + 1;
            end
        end
    end
    return tDes;
end

function  _Poker.C_M_5( srcTable )
    -- body
    local m = table.getn(srcTable);
    local n = 3;
    local index = 1;
    local tDes = {}; 
    for index1 = 1, m - n + 1 , 1 do
        for index2 = index1 + 1, m - 3, 1 do
            for index3 = index2 + 1, m - 2, 1 do
                for index4 = index3 + 1, m - 1, 1 do
                    for index5 = index4 + 1, m, 1 do
                        tDes[index] = {
                            srcTable[index1],srcTable[index2],srcTable[index3],srcTable[index4],srcTable[index5]
                        }
                        index = index + 1;
                    end
                end 
            end
        end
    end
    return tDes;
end
--[[
-------------------------------------------------
-------------------------------------------------
-- 定义CARD 的排序算法 主要包括用于卡牌的大小比较和排序,也可以用于单张牌比大小
-- example1
--  作为卡牌排序回掉
    local testCard = {...};
    table.sort(testCard,card_comp);  
    玩家组合的牌必须进行一次排序,方便对比与判断

-- example2
-- 作为普通卡牌比较
     card1 = {
        cardId = _Poker.CardIDType.Ace,        
        cardValue = _Poker.CardValues.Ace,
        cardSuit = _Poker.Suits.Spades,
        isUsed = false,
        exCardValue = nil,  --扩展值 比如斗地主中2为当局王，则需要将扑克牌中的2设置为较大值比如15 ,不同游戏卡牌不同设定
                            -- 设置颜色的修改同时在本局游戏中设定,不要修改默认的大小,所有的结果用户需要clone处理各个数据结构
     }
 card2 = {
        cardId = _Poker.CardIDType.Ace,        
        cardValue = _Poker.CardValues.Ace,
        cardSuit = _Poker.Suits.Spades,
        isUsed = false,
        exCardValue = nil,  --扩展值 比如斗地主中2为当局王，则需要将扑克牌中的2设置为较大值比如15 ,不同游戏卡牌不同设定
                            -- 设置颜色的修改同时在本局游戏中设定,不要修改默认的大小,所有的结果用户需要clone处理各个数据结构
     }
-- @param card1 卡牌1
-- @param card2 卡牌2
返回已经两张卡牌的大小
-------------------------------------------------
-------------------------------------------------
--]]


function _Poker.card_comp(card1,card2) 
    if card1.cardId  ~= card2.cardId then   
        -- 如果扩展值不为空 首先以扩展值比较
        local card1Value =  not card1.exCardValue and  card1.cardValue  or card1.exCardValue
        local card2Value =  not card2.exCardValue and  card2.cardValue or  card2.exCardValue
        
        --ngx.say(cjson.encode(card1))
        return card1Value > card2Value;
        --return card1Value > card2Value;
        
    else
        --ngx.say("cardSuit "..card1.cardSuit .. "cardSuit " .. card2.cardSuit)
        return card1.cardSuit > card2.cardSuit;
    end
end

function _Poker.max_comp(numb1,numb2) 
    return numb1 > numb2
end

-- 初始化扑克 结构
-- 调用之前需要用户修改相关卡牌的id大小默认为1-13 
-- 如果用户的卡牌为2>1>k 则需要将ace设置为14, Two 设置为15,一次内推
-- 如果用户卡牌不需要设置大小王,则传递空hasJoker的入参数即可
--[[
    cards = {
                {
                cardId = vid,
                cardSuit = vs,
                cardValue = self.CardValues[kid],   --用户value 值
                isUsed = false
            }
    }
    
]]


function _Poker:new(number,hasJoker)
-- 根据需要初始化的扑扑克返回扑克
    local cards = nil;
    local startIndex = 1;
    -- 需要大小王时,添加进入卡牌中
    if hasJoker then
        cards = {
            {cardId = self.CardIDType.RedJoker,
            cardSuit = nil,
            cardValue = self.CardValues.RedJoker
            },
            {cardId = self.CardIDType.BlackJoker, 
            cardSuit = nil,
            cardValue = self.CardValues.BlackJoker
            },
        }
        startIndex = 3;

    else
        cards = {}
    end

    local cardSuits = self.SuitType;
    local CardIDType = self.CardIDType;

    for ks,vs in pairs(cardSuits) do
        for kid,vid in pairs(CardIDType) do
            if "RedJoker" ~= kid and kid ~= "BlackJoker" then
                cards[startIndex] = {
                cardId = vid,
                cardSuit = vs,
                cardValue = self.CardValues[kid],   --用户value 值
                isUsed = false
            }
            startIndex = startIndex + 1;
            end
        end
    end

    local resultCards = {};
    for i = 1,number,1 do
        table.arrayMerge(resultCards,cards);
    end
    return resultCards;
end


function _Poker.get(poker)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local index = math.random(1, table.getn(poker))
    local card = poker[index]
    table.remove(poker, index)
    return card
end

_Poker.__index = _Poker;

return _Poker