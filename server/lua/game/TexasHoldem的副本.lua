--[[
-- 德州扑克的相关玩法以及大小判断
]]--

local Poker = require "game_t_h.poker"
local cjson = require "cjson"
--local TeaxsHoldem

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
local CardType = 
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


local TexasHoldemTable = {
    Blinds = 10,        --定义盲注 这个指总数
 
}

function bubble1(srcTable)
    local len = table.getn(srcTable);
    local index = 1;
    for i=1,len,1 do
        for j = index,len,1 do 
            local temp = srcTable[i];
        end
        index = index + 1;
    end

end

--[[
-- 定义自己的比较函数
local function my_comp(element1, elemnet2)
    return element1 >= elemnet2
end

local t1 = {4,50,20,3,4}
table.sort(t1,my_comp);
玩家组合的牌必须进行一次排序,方便对比与判断
]]
-- 定义自己的比较函数
function my_comp(element1, elemnet2)
    return element1 > elemnet2
end

local function my_comp2(element1, elemnet2)
    --return element1 >= elemnet2
    ngx.say(element1 .."  ".. elemnet2)
    return false;
end


--[[
-- 将 来源表格 中所有键及值复制到 目标表格 对象中，如果存在同名键，则覆盖其值
-- example

     
                Cards =  {
                    {CardId = PokerCardID.Ace,      Suit = PokerSuitType.Spades , IsUsed = 0},
                    {CardId = PokerCardID.King,     Suit = PokerSuitType.Spades , IsUsed = 0},
                    {CardId = PokerCardID.Queen,    Suit = PokerSuitType.Spades , IsUsed = 0},
                    {CardId = PokerCardID.Jack,     Suit = PokerSuitType.Spades , IsUsed = 0},
                    {CardId = PokerCardID.Ten,      Suit = PokerSuitType.Spades , IsUsed = 0}
                }
            
        local index = Juge(testTable)
-- @param testTable 玩家的数据结构
--]]

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
    
    cardtype_param = {
        isFlush = {result = false , suitSize = 5,suitType= nil},    -- suit 数量为1
        isStraight = {result = false , maxCardId = 0},              -- 是否 a a-1 a-2 a-3 a-4
        isFourOAK = {result = false , maxCardId = 0},               -- 是否 id 计数数组是否为2 其中一个为4,另一个为1, 只需要判断4个相同牌的那个大小
        isFullHouse = {result = false , maxCardId = 0},             -- 是否计数数组为2 并且为3,2, 只需要判断3个相同牌的那个大小
        isThreeOAK = {result = false , maxCardId = 0},              -- 是否为分类数组3，并且其中有一个为3,只需要判断3个相同牌的那个大小
        isTwoPairs = {result = false , status={}},                  -- 是否为分类数组3，并且其中两个为2,需要判断最大的2,然后判断第二个2,最后判断最后一个1
        isOnePair = {result = false ,  status={}},                  -- 是否分类数组为4，需要判断第一个2,同类型需要判断第一个2,然后按顺序判断最大的值截止
        isHighCard = {result = false , status={}}
    }
    cardtype_param_status = {
        suit_size = 0,
    }

]] 
function getCardType(cards)
        
        local len = table.getn(cards);

        local cardtype_param = {
        isFlush = {result = false , suitSize = 0},    -- suit 数量为1
        isStraight = {result = true , maxCardId = 0},              -- 是否 a a-1 a-2 a-3 a-4
        isFourOAK = {result = false , maxCardId = 0},               -- 是否 id 计数数组是否为2 其中一个为4,另一个为1, 只需要判断4个相同牌的那个大小
        isFullHouse = {result = false , maxCardId = 0},             -- 是否计数数组为2 并且为3,2, 只需要判断3个相同牌的那个大小
        isThreeOAK = {result = false , maxCardId = 0},              -- 是否为分类数组3，并且其中有一个为3,只需要判断3个相同牌的那个大小
        isTwoPairs = {result = false  },                  -- 是否为分类数组3，并且其中两个为2,需要判断最大的2,然后判断第二个2,最后判断最后一个1
        isOnePair = {result = false  },                  -- 是否分类数组为4，需要判断第一个2,同类型需要判断第一个2,然后按顺序判断最大的值截止
        isHighCard = {result = false },
        status = {},
        }
        local suitTemp = nil;
        for i = 1,len,1 do 
            local card = cards[i];
            -- 花色判断 ---------begin-----------
           if not suitTemp then 
                suitTemp = card.Suit;
            elseif suitTemp ~= card.Suit then
                cardtype_param.isFlush.suitSize = 2; 
           end
           ngx.say("suit is "..suitTemp.." "..card.Suit)
           if i == len and cardtype_param.isFlush.suitSize == 0 then 
                cardtype_param.isFlush.suitSize = 1;
                cardtype_param.isFlush.result = true;
           end
           -- 获得判断 ---------end-----------
           -- 顺子判断 ---------begin---------
           if i > 1 then 
                local lastCard = cards[i - 1];
                if lastCard.CardId - card.CardId ~= 1 then
                    cardtype_param.isStraight.result = false;
                end
           end
           -- 顺子判断 ---------end-----------

           -- N+N 判断 ---------begin---------
           if not cardtype_param.status[""..card.CardId] then
                cardtype_param.status[""..card.CardId] = 1;
            else
                cardtype_param.status[""..card.CardId] = cardtype_param.status[""..card.CardId]+1;
           end

           
        --[[end return cardtype_param;--]]
           if i == len then 
                local arraySize = 0;
                local arrayTable = {};
                for k,v in pairs(cardtype_param.status) do
                    arraySize = arraySize + 1;
                    arrayTable[arraySize] = v;
                end
                ngx.say(cjson.encode(arrayTable))
                -- 排序一次 进行大小获取
                table.sort(arrayTable,my_comp);
                -- 顺序进行判断
                if arraySize == 2 then
                    -- fouroak or fullhouse
                    if arrayTable[1] == 4 then 
                        cardtype_param.isFourOAK.result = true;
                        -- cardtype_param.isFourOAK.maxCardId = 
                        elseif arrayTable[1] == 3 then 
                        cardtype_param.isFullHouse.result = true;
                    end
                elseif arraySize == 3 then
                    -- 2+2+1 or 3+1+1
                    if arrayTable[1] == 3 then
                    cardtype_param.isThreeOAK.result = true;
                    else
                        cardtype_param.isTwoPairs.result = true;
                    end
                elseif arraySize == 4 then
                    -- 2+1+1+1
                        cardtype_param.isOnePair.result = true;
                else
                    -- 1+1+1+1+1+1
                        cardtype_param.isHighCard = true;
                end
           end
           -- 4 + 1 判断 ---------end-----------
        end


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

        -- 判断牌的状态
        local cardTypeResult = nil;
        if cardtype_param.isFlush.result and cardtype_param.isStraight.result then -- 是否为同花顺
            if cards[1].CardId == PokerCardID.Ace then      -- 是否为大同花顺
                cardTypeResult = CardType.RoyalFlush; 
            else
                cardTypeResult =  CardType.StrainghtFlush;
            end
        elseif  cardtype_param.isFourOAK.result then               -- 是否为4+1
                cardTypeResult = CardType.FourOfAKind;
        elseif  cardtype_param.isFullHouse.result then               -- 是否为3+2
                cardTypeResult = CardType.FullHouse;
        elseif  cardtype_param.isFlush.result then               -- 是否为3+2
                cardTypeResult = CardType.Flush;
        elseif  cardtype_param.isFlush.result then               -- 是否为同花
                cardTypeResult = CardType.Flush;
        elseif  cardtype_param.isStraight.result then               -- 是否为顺子
                cardTypeResult = CardType.Straight;
        elseif  cardtype_param.isThreeOAK.result then               -- 是否为3+1+1
                cardTypeResult = CardType.ThreeOfAKind;
         elseif  cardtype_param.isTwoPairs.result then               -- 是否为2+2+1
                cardTypeResult = CardType.TwoPairs;
         elseif  cardtype_param.isOnePair.result then               -- 是否为2+1+1+1
                cardTypeResult = CardType.OnePairs;
        else                                                      -- 是否为1+1+1+1+1
                cardTypeResult = CardType.HightCard;
        end
        
        return cardTypeResult,cardtype_param;
end



--[[
-- 将 来源表格 中所有键及值复制到 目标表格 对象中，如果存在同名键，则覆盖其值
-- example

     
        PokerCard = {
            CardId = PokerCardID.RedJoker;
            Suit = PokerSuitType.Hears;
            IsUsed = 1; -- 0表示已经使用 1表示未使用
        }

     local testTable={
            { Player_Id = 1, PlayerName = "Steven",PlayerMoney = 100,
                Cards =  {{CardId = PokerCardID.Ace,        Suit = PokerSuitType.Spades , IsUsed = 0},
                {CardId = PokerCardID.King,     Suit = PokerSuitType.Spades , IsUsed = 0},
                {CardId = PokerCardID.Queen,    Suit = PokerSuitType.Spades , IsUsed = 0},
                {CardId = PokerCardID.Jack,     Suit = PokerSuitType.Spades , IsUsed = 0},
                {CardId = PokerCardID.Ten,      Suit = PokerSuitType.Spades , IsUsed = 0}}
            },
            {  PlayerId = 2, PlayerName = "Tom",PlayerMoney = 100,
                Cards = {{CardId = PokerCardID.Ace,        Suit = PokerSuitType.Hears , IsUsed = 0},
                {CardId = PokerCardID.King,     Suit = PokerSuitType.Hears , IsUsed = 0},
                {CardId = PokerCardID.Queen,    Suit = PokerSuitType.Hears , IsUsed = 0},
                {CardId = PokerCardID.Jack,     Suit = PokerSuitType.Hears , IsUsed = 0},
                {CardId = PokerCardID.Ten,      Suit = PokerSuitType.Hears , IsUsed = 0}},
            },
           }
        local index = Juge(testTable)
-- @param testTable 玩家的数据结构
--]]
-- 第一步首先选出玩家手中最大的牌,将玩家牌和公共牌可组合的集合拿到,然后判断每一个牌的牌形,循环找出最大的牌组并返回
-- 第二步选出所有玩家手中最大的牌 类似以上操作
-- p1,p2都进行了一次牌的排序和牌型计算
function JugeCards(player1,player2)
    local cardsType1 = player1.cardType;
    local cardsType2 = player2.cardType;
    local cards1 = player1.cards;
    local cards2 = player2.cards;
    -- 牌型不相同,直接以牌型大的为大
    if cardsType1 ~= cardsType2 then
        return cardsType1 > cardsType2 and player1 or player2 ;
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
            return player1,true;   
        elseif cardsType1 == CardType.StrainghtFlush  or cardsType1 == CardType.Straight then
             -- 普通同花顺 和 顺子 判断第一个数字的大小 
             local card1 = cards1[1];
             local card2 = cards2[1];
             if card1.CardId ~= card2.CardId then
                return card1.CardId > card2.CardId and player1 or player2;
             else
                return card1.Suit > card2.Suit and player1 or player2;
             end

        elseif cardsType1 == CardType.FourOfAKind or cardsType1 == CardType.FullHouse or cardsType1 == CardType.ThreeOfAKind then
            -- 4+1 ,3+2 ,3+1+1 都是判断第三个数字的大小
            local card1 = cards1[3];
            local card2 = cards2[3];
            return card1.CardId > card2.CardId and player1 or player2;

        elseif cardsType1 == CardType.Flush or cardsType1 == CardType.HightCard then
                -- 如果是同花或高牌,进行循环判断
                for i = 1,5,1 do
                    local card1 = cards1[i];
                    local card2 = cards2[i];
                    if card1.CardId ~= card2.CardId then
                        return card1.CardId > card2.CardId and player1 or player2;
                    else
                        return card1.Suit > card2.Suit and player1 or player2;
                    end
                end

        elseif cardsType1 == CardType.TwoPairs then
            -- 2+2+1 的大小判断
            local cardtype_param1 = player1.cardtype_param;
            local cardtype_param2 = player2.cardtype_param; 
            local card1_pairs = {} ;
            local card1_index = 1;
            local card1_1 = nil;
            for k,v in pairs(cardtype_param1.status) do
                if v == 2 then
                    card1_pairs[card1_index] = tonumber(k);
                    card1_index = card1_index+1;
                else
                    card1_1 = tonumber(k);
                end
            end

            table.sort( card1_pairs, my_comp );
             
            local card2_pairs = {} ;
            local card2_index = 1;
            local card2_1 = nil;
            for k,v in pairs(cardtype_param2.status) do
                if v == 2 then
                    card2_pairs[card2_index] = tonumber(k);
                    card2_index = card2_index+1;
                 else
                    card2_1 = tonumber(k);
                end
                end
            end
            table.sort( card2_pairs, my_comp );
            
            if card1_pairs[1] ~= card2_pairs[1] then
                return card1_pairs[1] > card2_pairs[1] and player1 or player2;
            elseif card1_pairs[2] ~= card2_pairs[2] then
                return card1_pairs[2] > card2_pairs[2] and player1 or player2;   
            elseif card1_1 ~= card2_1 then 
                return card1_1 > card2_1 and player1 or player2;  
            else
                local suit1 = nil;
                 for i=1,5,1 in pairs(cards1) do
                    if card1_1 == cards1[i] then
                        suit1 = cards1[i].suitType;
                    end
                 end
                 local suit2 = nil;
                 for i=1,5,1 in pairs(cards2) do
                    if card2_1 == cards2[i] then
                        suit2 = cards2[i].suitType;
                    end
                 end
                  return suit1 > suit2 and player1 or player2;   
            end 
        else
            -- cardsType1 == CardType.OnePairs 
            -- 2+1+1+1 的大小判断
            local cardtype_param1 = player1.cardtype_param;
            local cardtype_param2 = player2.cardtype_param; 
            local 
        end

    end


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
function Juge(players)
    local len = table.getn(players);
    for i=1,len,1 do
        local player = players[i];
        player.cardType = getCardType(player.cards);
    end
    local maxPlayer = nil;
    for i=1,len,1 do
        local player = players[i];
        if not maxPlayer then 
            maxPlayer = player;
        else
            maxPlayer = JugeCards(maxPlayer,player)
        end
    end
    return maxPlayer;
end


--[[
-- 将 来源表格 中所有键及值复制到 目标表格 对象中，如果存在同名键，则覆盖其值
-- example
    
    
-- @param players 玩家数量
-- @param pokerSize 扑克牌数量
--]]
function TexasHoldemTable.new( players ,pokerSize)
    
end
--[[]]
local iniee = 10
ngx.say("hello"..10)

local t1 = {1,1,2,5,1}
table.sort(t1,my_comp);
for k,v in pairs(t1) do
    ngx.say(""..v)
end

local player = {
    cardType = nil;
    cards = { 
            {CardId = PokerCardID.King,     Suit = PokerSuitType.Spades , IsUsed = 0},
            {CardId = PokerCardID.Jack,    Suit = PokerSuitType.Spades , IsUsed = 0},
            {CardId = PokerCardID.Jack,     Suit = PokerSuitType.Hears , IsUsed = 0},
            {CardId = PokerCardID.Jack,      Suit = PokerSuitType.Clubs , IsUsed = 0},
            {CardId = PokerCardID.Jack,      Suit = PokerSuitType.diamons , IsUsed = 0},
    },
    cardtype_param = {}
}

--ngx.say(cjson.encode(TestCards))
player.cardType,player.cardtype_param = getCardType(player.cards)
 for k,v in pairs(player.cardtype_param.status) do
    ngx.say("key "..k .. "  value "..v)
 end

ngx.say(cjson.encode(player.cardtype_param))

