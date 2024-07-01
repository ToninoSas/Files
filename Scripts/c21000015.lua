-- Soccorso S.A.F.
local s, id = GetID()

function s.initial_effect(c)
    -- Special Summon from Graveyard
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.spsumtg)
    e1:SetOperation(s.spsumop)
    c:RegisterEffect(e1)
    
    -- Second effect: Protect SAF monsters from being destroyed by card effects
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x81c) -- Replace 0x81c with the actual "S.A.F." archetype code
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spsumtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.spsumop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.repfilter(c,tp)
    return  c:IsControler(tp) and c:IsOnField()
    and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x81c)
end


function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)

end

function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    -- local tc=Duel.GetFirstTarget()
    -- if tc and tc:IsRelateToEffect(e) and e:GetHandler():IsAbleToRemove() then
    --     Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
    --     Duel.NegateEffect(ev)
    -- end

    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end