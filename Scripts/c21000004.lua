--Viestano, il guerriero S.A.F.
local s, id = GetID()

function c21000004.initial_effect(c)
    -- Effect: Special Summon "Hyundai I10, il veicolo S.A.F." from Deck or hand when Normal Summoned
    local e1 = Effect.CreateEffect(c)
    -- e1:SetDescription(aux.Stringid(c21000004, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(c21000004.sptg)
    e1:SetOperation(c21000004.spop)
    c:RegisterEffect(e1)
end

function c21000004.spfilter(c, e, tp)
    return c:IsCode(21000005) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) -- Replace 12345678 with the actual card ID of "Hyundai I10, il veicolo S.A.F."
end

function c21000004.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(c21000004.spfilter, tp, LOCATION_DECK + LOCATION_HAND, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_HAND)
end

function c21000004.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, c21000004.spfilter, tp, LOCATION_DECK + LOCATION_HAND, 0, 1, 1, nil, e, tp)
    if g:GetCount() > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end

