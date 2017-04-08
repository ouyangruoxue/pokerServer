--[[
-- 德州扑克的相关玩法以及大小判断
]]--

 
local Poker = require "game.poker.TexasHoldemPoker"
local cjson  = require "cjson"


local _TexasHoldem = {}

 --[[
    -- 牌型
    皇家同花顺(royal flush)：由AKQJ10五张组成，并且这5张牌花色相同 　　  
    同花顺(straight flush)：由五张连张同花色的牌组成 　　
    4条(four of a kind)：4张同点值的牌加上一张其他任何牌 　　
    满堂红(full house)（又称“葫芦”）：3张同点值加上另外一对 　　
    同花(flush)：5张牌花色相同，但是不成顺子 　　
    顺子(straight)：五张牌连张，至少一张花色不同 　　
    3条(three of a kind)：三张牌点值相同，其他两张各异 　　
    两对(two pairs)：两对加上一个杂牌 　　
    一对(one pair)：一对加上3张杂牌 　　
    高牌(high card)：不符合上面任何一种牌型的牌型，由单牌且不连续不同花的组成
 ]]
_TexasHoldem.CardType = 
{
    RoyalFlush  = 10,
    StrainghtFlush = 9,
    FourOfAKind = 8,
    FullHouse = 7,
    Flush = 6,
    Straight = 5,
    ThreeOfAKind = 4,
    TwoPairs = 3,
    OnePairs = 2,
    HightCard = 1,
}
_TexasHoldem.CardTypeDescription = 
{
    "高牌(high card)：不符合上面任何一种牌型的牌型，由单牌且不连续不同花的组成",
    "一对(one pair)：一对加上3张杂牌",
    "两对(two pairs)：两对加上一个杂牌 ",
    "3条(three of a kind)：三张牌点值相同，其他两张各异",
    "顺子(straight)：五张牌连张，至少一张花色不同",
    "同花(flush)：5张牌花色相同，但是不成顺子",
    "满堂红(full house)（又称“葫芦”）：3张同点值加上另外一对",
    "4条(four of a kind)：4张同点值的牌加上一张其他任何牌 ",
    "同花顺(straight flush)：由五张连张同花色的牌组成",
    "皇家同花顺(royal flush)：由AKQJ10五张组成，并且这5张牌花色相同",
}
local CardType = _TexasHoldem.CardType;

--[[
    自定义比较函数,以size大小为主

    cmp1 = {
            cardSize = 1,
            cardValue = cards[i].cardValue,
            cards = { 
                cards[i]
            }
]]
function cardsTypeCmp(cmp1,cmp2)
    
    if cmp1.cardSize ==  cmp2.cardSize then
        return cmp1.cardValue > cmp2.cardValue;
    end
    return cmp1.cardSize > cmp2.cardSize;
end

--[[
    判断是否为同花,如果为同花,返回当前同花类型
    如果非同花顺,则返回其他相应的牌的状态
    皇家同花顺(royal flush)：由AKQJ10五张组成，并且这5张牌花色相同 　　  
    同花顺(straight flush)：由五张连张同花色的牌组成 　　
    4条(four of a kind)：4张同点值的牌加上一张其他任何牌 　　
    满堂红(full house)（又称“葫芦”）：3张同点值加上另外一对 　　
    同花(flush)：5张牌花色相同，但是不成顺子 　　
    顺子(straight)：五张牌连张，至少一张花色不同 　　
    3条(three of a kind)：三张牌点值相同，其他两张各异 　　
    两对(two pairs)：两对加上一个杂牌 　　
    一对(one pair)：一对加上3张杂牌 　　
    高牌(high card)：不符合上面任何一种牌型的牌型，由单牌且不连续不同花的组成
 
    遍历过程进行多种状态遍历 
    1 是否同色 
    2 是否顺子 
    3 是否有4+1
    4 是否3+2 
    5 是否3+1+1 
    6 是否2+2+1
    7 是否2+1+1+1
    8 1+1+1+1+1 


-- @param cards 用户5张卡牌的数组
-- @return 返回用户的卡牌类型,用户新的卡牌顺序
]] 
function _TexasHoldem.getCardType(cards)
        
        local len = table.getn(cards);
        local cardtype_param = {
        isFlush = {result = false , suitSize = 0},    -- suit 数量为1
        isStraight = {result = true , maxcardId = 0},              -- 是否 a a-1 a-2 a-3 a-4
        isFourOAK = {result = false , maxcardId = 0},               -- 是否 id 计数数组是否为2 其中一个为4,另一个为1, 只需要判断4个相同牌的那个大小
        isFullHouse = {result = false , maxcardId = 0},             -- 是否计数数组为2 并且为3,2, 只需要判断3个相同牌的那个大小
        isThreeOAK = {result = false , maxcardId = 0},              -- 是否为分类数组3，并且其中有一个为3,只需要判断3个相同牌的那个大小
        isTwoPairs = {result = false  },                  -- 是否为分类数组3，并且其中两个为2,需要判断最大的2,然后判断第二个2,最后判断最后一个1
        isOnePair = {result = false  },                  -- 是否分类数组为4，需要判断第一个2,同类型需要判断第一个2,然后按顺序判断最大的值截止
        isHighCard = {result = false },
        status = {},
        }
        local suitTemp = nil;
        -- 用户牌中相同牌形的排序
        -- 减少判断逻辑
        local cardIdIndex = 1;
        local cardIdTypes = 0;
        for i = 1,len,1 do 
            local card = cards[i];
            -- 花色判断 ---------begin-----------
           if not suitTemp then 
                suitTemp = card.cardSuit;
            elseif suitTemp ~= card.cardSuit then
                cardtype_param.isFlush.suitSize = 2; 
           end
           -- ngx.say("suit is "..suitTemp.." "..card.Suit)
           if i == len and cardtype_param.isFlush.suitSize == 0 then 
                cardtype_param.isFlush.suitSize = 1;
                cardtype_param.isFlush.result = true; 
           end
           -- 获得判断 ---------end-----------
           -- 顺子判断 ---------begin---------
           if i > 1 then 
                local lastCard = cards[i - 1];
                if lastCard.cardValue - card.cardValue ~= 1 then
                    cardtype_param.isStraight.result = false;
                end
           end
           -- 顺子判断 ---------end-----------

           -- N+N 判断 ---------begin---------
           if not cardtype_param.status[cardIdIndex] then
                cardtype_param.status[cardIdIndex] = {
                    cardSize = 1,
                    cardValue = cards[i].cardValue,
                    cards = { 
                        cards[i]
                    }
                } 
            else
                if cardtype_param.status[cardIdIndex].cardValue == cards[i].cardValue then
                    local _temSize = cardtype_param.status[cardIdIndex].cardSize + 1;
                    cardtype_param.status[cardIdIndex].cardSize = _temSize;
                    cardtype_param.status[cardIdIndex].cards[_temSize] = cards[i];
                else
                    cardIdIndex = cardIdIndex + 1;
                    cardtype_param.status[cardIdIndex] = {
                        cardSize = 1,
                        cardValue = cards[i].cardValue,
                        cards = { 
                            cards[i]
                        }
                    } 
                end
            end
        end  
        --[[end return cardtype_param;--]]  
        -- 排序一次 进行大小获取
        table.sort(cardtype_param.status,cardsTypeCmp);
        local statusArray = cardtype_param.status;
        local newCards = nil;
        -- ngx.say(cjson.encode(cardtype_param.status))
       
        -- 顺序进行判断
        if cardIdIndex == 2 then
            -- fouroak or fullhouse
            if statusArray[1].cardSize == 4 then 
                cardtype_param.isFourOAK.result = true;
                -- cardtype_param.isFourOAK.maxcardId = 
                elseif statusArray[1].cardSize == 3 then 
                cardtype_param.isFullHouse.result = true;
            end
        elseif cardIdIndex == 3 then
            -- 2+2+1 or 3+1+1
            if statusArray[1].cardSize == 3 then
            cardtype_param.isThreeOAK.result = true;
            else
                cardtype_param.isTwoPairs.result = true;
            end
        elseif cardIdIndex == 4 then
            -- 2+1+1+1
                cardtype_param.isOnePair.result = true;
        else
            -- 1+1+1+1+1+1
                cardtype_param.isHighCard = true;
        end
          
        -- 4 + 1 判断 ---------end-----------
 
        local newCards = nil;
        -- 判断牌的状态
        local cardTypeResult = nil;
        if cardtype_param.isFlush.result and cardtype_param.isStraight.result then -- 是否为同花顺
            if cards[1].cardId == Poker.CardIDType.Ace then      -- 是否为大同花顺
                cardTypeResult = CardType.RoyalFlush; 
            else
                cardTypeResult =  CardType.StrainghtFlush;
            end
        elseif  cardtype_param.isFourOAK.result then               -- 是否为4+1
                cardTypeResult = CardType.FourOfAKind;
                local card1Temp = cards[1];
                -- 获取第三张牌
                local card3 = cards[3];
                if card3.cardId ~= card1Temp.cardId then
                    -- 说明第一张是不同数字的 重新排序
                    newCards = {
                        cards[2],cards[3],cards[4],cards[5],cards[1],
                    };
                end


        elseif  cardtype_param.isFullHouse.result then               -- 是否为3+2
                cardTypeResult = CardType.FullHouse;
                 local card1Temp = cards[1];
                -- 获取第三张牌
                local card3 = cards[3];
                if card3.cardId ~= card1Temp.cardId then
                    -- 说明第一张是不同数字的 重新排序
                    newCards = {
                        cards[3],cards[4],cards[5],cards[1],cards[2],
                    };
                end


        elseif  cardtype_param.isFlush.result then               -- 是否为同花
                cardTypeResult = CardType.Flush;
        elseif  cardtype_param.isStraight.result then               -- 是否为顺子
                cardTypeResult = CardType.Straight;
        elseif  cardtype_param.isThreeOAK.result then               -- 是否为3+1+1
                cardTypeResult = CardType.ThreeOfAKind;
                if cards[2].cardId == cards[4].cardId then
                    newCards = {
                        cards[2],cards[3],cards[4],cards[1],cards[5],
                    };
                elseif cards[3].cardId == cards[5].cardId then
                    newCards = {
                        cards[3],cards[4],cards[5],cards[1],cards[2],
                    };
                end


        elseif  cardtype_param.isTwoPairs.result then               -- 是否为2+2+1 
                cardTypeResult = CardType.TwoPairs;
                newCards = {
                        statusArray[1].cards[1],
                        statusArray[1].cards[2],
                        statusArray[2].cards[1],
                        statusArray[2].cards[2],
                        statusArray[3].cards[1],
                    };


        elseif  cardtype_param.isOnePair.result then               -- 是否为2+1+1+1 
                cardTypeResult = CardType.OnePairs;
                -- 获取当前多组cards 的数组信息
                  newCards = {
                        statusArray[1].cards[1],
                        statusArray[1].cards[2],
                        statusArray[2].cards[1],
                        statusArray[3].cards[1],
                        statusArray[4].cards[1],
                    };
        else                                               
                -- 是否为1+1+1+1+1
                cardTypeResult = CardType.HightCard;
        end
 
        --[[ 2+2+1 2+1+1+1 需要重新把牌的位置进行排序]]
        if not newCards then newCards = cards end

        -- 排序处理结束
        return cardTypeResult,newCards;
end




--[[
-- 将 来源表格 中所有键及值复制到 目标表格 对象中，如果存在同名键，则覆盖其值
-- example 
    PokerCard = {
        cardId = PokercardId.RedJoker;
        Suit = PokerSuitType.Hears;
        IsUsed = 1; -- 0表示已经使用 1表示未使用
    } 

    local testTable={
        { Player_Id = 1, PlayerName = "Steven",PlayerMoney = 100,
            Cards =  {{cardId = PokercardId.Ace,        Suit = PokerSuitType.Spades , IsUsed = 0},
            {cardId = PokercardId.King,     Suit = PokerSuitType.Spades , IsUsed = 0},
            {cardId = PokercardId.Queen,    Suit = PokerSuitType.Spades , IsUsed = 0},
            {cardId = PokercardId.Jack,     Suit = PokerSuitType.Spades , IsUsed = 0},
            {cardId = PokercardId.Ten,      Suit = PokerSuitType.Spades , IsUsed = 0}}
        },
        {  PlayerId = 2, PlayerName = "Tom",PlayerMoney = 100,
            Cards = {{cardId = PokercardId.Ace,        Suit = PokerSuitType.Hears , IsUsed = 0},
            {cardId = PokercardId.King,     Suit = PokerSuitType.Hears , IsUsed = 0},
            {cardId = PokercardId.Queen,    Suit = PokerSuitType.Hears , IsUsed = 0},
            {cardId = PokercardId.Jack,     Suit = PokerSuitType.Hears , IsUsed = 0},
            {cardId = PokercardId.Ten,      Suit = PokerSuitType.Hears , IsUsed = 0}},
        },
    }
    local index = Juge(testTable)

-- @param player1 玩家的数据结构
-- @param player2 玩家的数据结构
    返回当前最大的卡牌,true 卡牌1大/ false 卡牌2大,卡牌1的类型,卡牌2的类型
--]]
-- 第一步首先选出玩家手中最大的牌,将玩家牌和公共牌可组合的集合拿到,然后判断每一个牌的牌形,循环找出最大的牌组并返回
-- 第二步选出所有玩家手中最大的牌 类似以上操作
-- p1,p2都进行了一次牌的排序和牌型计算
local CardsEqualResult =  Poker.CardsEqualResult;
function _TexasHoldem.JugeCards(cards1,cards2)
   local cardsType1 , cards1 = _TexasHoldem.getCardType(cards1);
   local cardsType2 , cards2 = _TexasHoldem.getCardType(cards2);
    
    -- 两副牌中那个比较大
    local cards_a_b = nil;
    -- 牌型不相同,直接以牌型大的为大
    if cardsType1 ~= cardsType2 then
        return cardsType1 > cardsType2 and cards1 or cards2 ,cardsType1 > cardsType2 and CardsEqualResult.Greater or CardsEqualResult.Less, cardsType1,cardsType2;
    else
        -- 牌形相同,根据牌形类型进行比较
        --[[
        -- 牌型
        RoyalFlush  = 10,            皇家同花顺(royal flush)：由AKQJ10五张组成，并且这5张牌花色相同 　　  
        StrainghtFlush = 9,            同花顺(straight flush)：由五张连张同花色的牌组成 　　
        FourOfAKind = 8,            4条(four of a kind)：4张同点值的牌加上一张其他任何牌 　　
        FullHouse = 7,            满堂红(full house)（又称“葫芦”）：3张同点值加上另外一对 　　
        Flush = 6,            同花(flush)：5张牌花色相同，但是不成顺子 　　
        Straight = 5,            顺子(straight)：五张牌连张，至少一张花色不同 　　
        ThreeOfAKind = 4,            3条(three of a kind)：三张牌点值相同，其他两张各异 　　
        TwoPairs = 3,            两对(two pairs)：两对加上一个杂牌 　　
        OnePairs = 2,            一对(one pair)：一对加上3张杂牌 　　
        HightCard = 1,            高牌(high card)：不符合上面任何一种牌型的牌型，由单牌且不连续不同花的组成
        ]]

        if cardsType1 == CardType.RoyalFlush then
             --  皇家同花顺,平局
            return cards1,CardsEqualResult.Equal,cardsType1,cardsType2;  
        else 
            for i = 1,5,1 do
                local card1 = cards1[i];
                local card2 = cards2[i];
                if card1.cardValue ~= card2.cardValue then
                    local cardsize = cards1[i].cardValue > cards2[i].cardValue ;
                    return cardsize and cards1 or cards2 , cardsize and CardsEqualResult.Greater or CardsEqualResult.Less, cardsType1,cardsType2;
                else
                    if i == 5 then 
                        return cards1, CardsEqualResult.Equal, cardsType1,cardsType2;
                    end
                end 
            end
        end
    end 
end


function _TexasHoldem.JugePlayerCards(player1,player2)
    local cards1 = player1.cards;
    local cards2 = player2.cards;
    local cards,isPlayer1 = _TexasHoldem.JugeCards(cards1,cards2)
    if CardsEqualResult.Greater == isPlayer1 then 
        return player1
    elseif CardsEqualResult.Less == isPlayer1 then
        return player2
    else
        return player1
    end

end


--[[
-- 将 用户底牌和公共牌 返回所有可组合的对象列表
-- example 
    local userPriCards = { 
            {cardId = PokercardId.King,     Suit = PokerSuitType.Spades , IsUsed = 0},
            {cardId = PokercardId.Queen,    Suit = PokerSuitType.Spades , IsUsed = 0},
    } 
    local sharedCards = {
            {cardId = PokercardId.King,     Suit = PokerSuitType.Hears , IsUsed = 0},
            {cardId = PokercardId.Queen,    Suit = PokerSuitType.Hears , IsUsed = 0},
            {cardId = PokercardId.Jack,     Suit = PokerSuitType.Hears , IsUsed = 0},
            {cardId = PokercardId.Ten,      Suit = PokerSuitType.Hears , IsUsed = 0}
    }

-- @param userPriCards 玩家的底牌
-- @param sharedCards  牌桌上的公共牌 3-5张
-- 返回该组中用户最大的牌
--]]
function  _TexasHoldem.getUsersMaxCards(userPriCards,sharedCards )
    -- body
    -- 1 生成将手牌以及共享牌合并成一个数组
    table.arrayMerge(userPriCards,sharedCards);

    -- 2 返回所有公共牌中的5张组合列表
    local fiveCards = Poker.C_M_5(userPriCards);
    -- 3 组合生成用户的所有卡牌
    local fiveLen = table.getn(fiveCards);
    
    for i = 1,fiveLen,1 do 
        -- 默认排序一次
        table.sort(fiveCards[i],Poker.card_comp);
        -- ngx.say(cjson.encode(fiveCards[i]))
        -- ngx.say(table.getn(fiveCards[i]))
    end
    -- 4 循环比较卡牌中最大的牌 并返回
    local maxCards = nil;
--[[]]
    local res, type1, type2
    for i = 1,fiveLen,1 do
        if not maxCards then 
            maxCards = fiveCards[i];
        else
            maxCards, res, type1, type2 = _TexasHoldem.JugeCards(maxCards,fiveCards[i]);

        end 
    end
    return maxCards, res > 0 and type1 or type2;
    
end


--[[
    如果函数返回nil表明都是皇家同花顺,否则返回的为最大的玩家的信息
]]

--[[
-- 返回玩家队列中最大的玩家信息, 如果函数返回nil表明都是皇家同花顺,否则返回的为最大的玩家的信息,
-- 取桌面上的公共牌来组合最大的个人牌的时候也调用该函数,只是所有的playerid为相同而已
-- example
    
    
-- @param players 玩家数组
--]]
function _TexasHoldem.Juge(players)
    local len = table.getn(players);
    for i=1,len,1 do
        local player = players[i];
        player.cardType = _TexasHoldem.getCardType(player.cards);
    end
    local maxPlayer = nil;
    for i=1,len,1 do
        local player = players[i];
        if not maxPlayer then 
            maxPlayer = player;
        else
            maxPlayer = _TexasHoldem.JugePlayerCards(maxPlayer,player)
        end
    end
    return maxPlayer;
end



--[[
     Action  = 1,     --叫注 / 说话 一个玩家的决定共有七种。
]]
local PlayerActions = { 
    Bet     = 1,        --押注 - 押上筹码
    Call    = 2,       --跟进 - 跟随众人押上同等的注额
    Fold    = 3,       --收牌 / 不跟 - 放弃继续牌局的机会
    Check   = 4,       --让牌 - 在无需跟进的情况下选择把决定“让”给下一位
    Raise   = 5,       --加注 - 把现有的注金抬高
    ReRaise = 6,       --再加注 - 再别人加注以后回过来再加注
    AllIn   = 7,       --全押 - 一次过把手上的筹码全押上 
}

--[[
Betting Rounds 押注圈 - 每一个牌局可分为四个押注圈。每一圈押注由按钮(庄家)左侧的玩家开始叫注。
]]

local BettingRounds = {
        Pre_flop = 1,       --底牌权 / 前翻牌圈 - 公共牌出现以前的第一轮叫注。
        Flop_round = 2,     --翻牌圈 - 首三张公共牌出现以后的押注圈 。
        Turn_round = 3,     --转牌圈 - 第四张公共牌出现以后的押注圈 。
        River_round =4,     --河牌圈 - 第五张公共牌出现以后 , 也即是摊牌以前的押注圈 。
}

--[[
    在每一局开始时,台面上必须有“盲注”。
    这是对玩家强制性的押注,为的是确保“底池”(每一牌局的奖金)至少有个数。德州扑克里的盲注一般由按钮左侧的两人付出。
]]
local PlayerStatus = {
    Offine = 0 ,        --掉线/离线
    Playing = 1,        --正常进行
    Watch = 2,          --观望 
    Bust = 3,           --出局
    
}

local PlayerRole = {
    Dealer = 1 , -- 庄家
    Door = 2,   -- 散户
}

local Player = {
    PlayerId = 0,  --玩家ID
    PlayerName = "玩家N",
    PlayerMoney = 100, -- 玩家金钱
    PlayerRole = PlayerRole.Dealer,
    PlayerStatus = PlayerStatus.Watch,
    Cards = {}
}

Player.__Index = Player;

function Player.new(self,playerId)
    local tDes = setmetatable({}, Player)  
    tDes.PlayerId = playerId;
    return   tDes;
end

function Player.Action(self)
    

end
  
local player = {
    cardType = nil;
    cards = { 
            {cardId = Poker.CardIDType.King,     Suit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Queen,    Suit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,     Suit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Ten,      Suit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,     Suit = Poker.SuitType.Spades , IsUsed = 0},
    }, 
}

local player1 = {
    cardType = nil;
    cards = { 
            
            {cardId = Poker.CardIDType.Ace,   cardValue = Poker.CardValues.Ace,    cardSuit = Poker.SuitType.Clubs , IsUsed = 0},
            {cardId = Poker.CardIDType.Ace,   cardValue = Poker.CardValues.Ace,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Ten,   cardValue = Poker.CardValues.Ten,    cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,  cardValue = Poker.CardValues.Jack,   cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,  cardValue = Poker.CardValues.Jack,   cardSuit = Poker.SuitType.Hears , IsUsed = 0},
           
    }, 
}





--[[
    模拟皇家同花顺
]]


local testCards_RoyalFlush = { 
            {cardId = Poker.CardIDType.Ace,    cardValue = Poker.CardValues.Ace,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.King,   cardValue = Poker.CardValues.King,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Ten,    cardValue = Poker.CardValues.Ten,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Queen,  cardValue = Poker.CardValues.Queen,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
        }

 
table.sort(testCards_RoyalFlush,Poker.card_comp);

--ngx.say("result #2  testCards_RoyalFlush: ",cjson.encode(testCards_RoyalFlush));
local cardType , newcard = _TexasHoldem.getCardType(testCards_RoyalFlush);
--ngx.say("result #3  testCards_RoyalFlush: ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])
-- ngx.say(cjson.encode(newcard))

 

local testCards_StrainghtFlush = { 
            {cardId = Poker.CardIDType.Nine,    cardValue = Poker.CardValues.Nine,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.King,   cardValue = Poker.CardValues.King,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Ten,    cardValue = Poker.CardValues.Ten,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Queen,  cardValue = Poker.CardValues.Queen,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
        }

 
table.sort(testCards_StrainghtFlush,Poker.card_comp);
--ngx.say("result #2  StrainghtFlush: ",cjson.encode(testCards_StrainghtFlush));
cardType , newcard = _TexasHoldem.getCardType(testCards_StrainghtFlush);
--ngx.say("result #3  StrainghtFlush: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])



local testCards_FourOfAKind = { 
            {cardId = Poker.CardIDType.Nine,    cardValue = Poker.CardValues.Nine,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,   cardValue = Poker.CardValues.Nine,     cardSuit = Poker.SuitType.Hears , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,    cardValue = Poker.CardValues.Nine,    cardSuit = Poker.SuitType.Clubs , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,  cardValue = Poker.CardValues.Nine,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
        }

 
table.sort(testCards_FourOfAKind,Poker.card_comp);
--ngx.say("result #2  FourOfAKind: ",cjson.encode(testCards_FourOfAKind));
cardType , newcard = _TexasHoldem.getCardType(testCards_FourOfAKind);
--ngx.say("result #3  FourOfAKind: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])




local testCards_FullHouse = { 
            {cardId = Poker.CardIDType.Nine,    cardValue = Poker.CardValues.Nine,    cardSuit = Poker.SuitType.Spades  , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,   cardValue = Poker.CardValues.Nine,     cardSuit = Poker.SuitType.Hears   , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,    cardValue = Poker.CardValues.Nine,     cardSuit = Poker.SuitType.Clubs   , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,  cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
        }

 
table.sort(testCards_FullHouse,Poker.card_comp);
--ngx.say("result #2  FullHouse: ",cjson.encode(testCards_FullHouse));
cardType , newcard = _TexasHoldem.getCardType(testCards_FullHouse);
--ngx.say("result #3  FullHouse: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])



local testCards_Flush = { 
            {cardId = Poker.CardIDType.Two,    cardValue = Poker.CardValues.Two,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.King,   cardValue = Poker.CardValues.King,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Ten,    cardValue = Poker.CardValues.Ten,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Queen,  cardValue = Poker.CardValues.Queen,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
       }

 
table.sort(testCards_Flush,Poker.card_comp);
--ngx.say("result #2  Flush: ",cjson.encode(testCards_Flush));
cardType , newcard = _TexasHoldem.getCardType(testCards_Flush);
--ngx.say("result #3  Flush: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])



local testCards_Straight = { 
            {cardId = Poker.CardIDType.Nine,    cardValue = Poker.CardValues.Nine,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.King,   cardValue = Poker.CardValues.King,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Ten,    cardValue = Poker.CardValues.Ten,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Queen,  cardValue = Poker.CardValues.Queen,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
       }

 
table.sort(testCards_Straight,Poker.card_comp);
--ngx.say("result #2  Straight: ",cjson.encode(testCards_Straight));
cardType , newcard = _TexasHoldem.getCardType(testCards_Straight);
--ngx.say("result #3  Straight: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])


local testCards_ThreeOfAKind = { 
            {cardId = Poker.CardIDType.King,    cardValue = Poker.CardValues.King,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.King,   cardValue = Poker.CardValues.King,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.King,    cardValue = Poker.CardValues.King,      cardSuit = Poker.SuitType.Clubs , IsUsed = 0},
            {cardId = Poker.CardIDType.Queen,  cardValue = Poker.CardValues.Queen,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
       }

 
table.sort(testCards_ThreeOfAKind,Poker.card_comp);
--ngx.say("result #2  ThreeOfAKind: ",cjson.encode(testCards_ThreeOfAKind));
cardType , newcard = _TexasHoldem.getCardType(testCards_ThreeOfAKind);
--ngx.say("result #3  ThreeOfAKind: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])


local testCards_TwoPairs = { 
            {cardId = Poker.CardIDType.Ten,    cardValue = Poker.CardValues.Ten,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.Ten,   cardValue = Poker.CardValues.Ten,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,    cardValue = Poker.CardValues.Nine,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,  cardValue = Poker.CardValues.Nine,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
       }

 
table.sort(testCards_TwoPairs,Poker.card_comp);
--ngx.say("result #2  TwoPairs: ",cjson.encode(testCards_TwoPairs));
cardType , newcard = _TexasHoldem.getCardType(testCards_TwoPairs);
--ngx.say("result #3  TwoPairs: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])


local testCards_OnePairs = { 
            {cardId = Poker.CardIDType.Ace,    cardValue = Poker.CardValues.Ace,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.Ace,   cardValue = Poker.CardValues.Ace,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Ten,    cardValue = Poker.CardValues.Ten,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Queen,  cardValue = Poker.CardValues.Queen,    cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
       }

 
table.sort(testCards_OnePairs,Poker.card_comp);
--ngx.say("result #2  OnePairs: ",cjson.encode(testCards_OnePairs));
cardType , newcard = _TexasHoldem.getCardType(testCards_OnePairs);
--ngx.say("result #3  OnePairs: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])



local testCards_HightCard = { 
            {cardId = Poker.CardIDType.Ace,    cardValue = Poker.CardValues.Ace,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.Nine,   cardValue = Poker.CardValues.Nine,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Two,    cardValue = Poker.CardValues.Two,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Five,  cardValue = Poker.CardValues.Five,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
            {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
       }

 
table.sort(testCards_HightCard,Poker.card_comp);
--ngx.say("result #2  HightCard: ",cjson.encode(testCards_HightCard));
cardType , newcard = _TexasHoldem.getCardType(testCards_HightCard);
--ngx.say("result #3  HightCard: ",cardType," ",cjson.encode(newcard));
--ngx.say("result #4  牌型为:",cardType," ------",_TexasHoldem.CardTypeDescription[cardType])

--[[

local resultCards ,isCard1Biger,card1Type,card2Type = _TexasHoldem.JugeCards(testCards_FourOfAKind,testCards_FullHouse)
ngx.say(isCard1Biger and "卡牌1较大" or "卡牌2较大",card1Type,isCard1Biger and " > " or " < ",card2Type)
ngx.say(cjson.encode(resultCards))

local priData = { 
            {cardId = Poker.CardIDType.Five,    cardValue = Poker.CardValues.Five,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
            {cardId = Poker.CardIDType.Six,     cardValue = Poker.CardValues.Six,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
        }
ngx.say("-------------------")
local reData,ct = _TexasHoldem.getUsersMaxCards(priData,testCards_RoyalFlush);
ngx.say(cjson.encode(reData))
ngx.say(_TexasHoldem.CardTypeDescription[ct])
--local players = {
--    player,player1
--}

--table.sort(player1.cards,card_comp)
--player1.cardType,player1.cards = _TexasHoldem.getCardType(player1.cards)
--]]
--[[
local  begin_time = ngx.now();
local playerWIN = JugeCards(player,player1);
ngx.say(cjson.encode(playerWIN))

local request_time = ngx.now() - begin_time 
ngx.say("result #3: ",request_time)
]]
--ngx.say(cjson.encode(player1))
--]]


--ngx.header.content_type="application/json"
--ngx.header['Content-Type']="text/html;charset=UTF-8"
--ngx.header["X-Server-By"] = 'server by surjur'
--ngx.header["Server"] = 'nginx'
--ngx.header["X-Server-End"] = request_time


 return _TexasHoldem