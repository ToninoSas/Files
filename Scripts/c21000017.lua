-- giada e carella gli alcolisti SAF
local s, id = GetID()
function s.initial_effect(c)
    -- Synchro Summon
    -- Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99) EDO PRO

    aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1, 1)

    c:EnableReviveLimit()
    
    -- Special Summon S.A.F. monster from Graveyard
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Gain LP or banish S.A.F. cards when used as Synchro material
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_COIN + CATEGORY_RECOVER + CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1, id)
    e2:SetCondition(s.coincon)
    e2:SetTarget(s.cointg)
    e2:SetOperation(s.coinop)
    c:RegisterEffect(e2)
end

s.toss_coin = true

-- Special Summon condition
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x81c) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- Special Summon target
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsSetCard(0x81c) end
    if chk == 0 then return Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

-- Special Summon operation
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- Coin toss condition
function s.coincon(e, tp, eg, ep, ev, re, r, rp)
    return r == REASON_SYNCHRO
end

-- Coin toss target
function s.cointg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        local deckCount = Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)
        local graveCount = Duel.GetFieldGroupCount(tp, LOCATION_GRAVE, 0)
        return Duel.IsPlayerCanRemove(tp) and (deckCount >= 2 or graveCount >= 2) 
    end
    Duel.SetOperationInfo(0, CATEGORY_COIN, nil, 0, tp, 1)
end

-- Coin toss operation
function s.coinop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local res = Duel.TossCoin(tp, 1)
    if res == 1 then
        Duel.Recover(tp, 1000, REASON_EFFECT)
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local g = Duel.SelectMatchingCard(tp, Card.IsSetCard, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 2, 2, nil, 0x81c)
        if #g > 0 then
            Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
        end
    end
end
