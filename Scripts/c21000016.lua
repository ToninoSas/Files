-- Concessione S.A.F.
local s, id = GetID()

function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_END_PHASE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c, e, tp)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x81c)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil, e, tp)
            or Duel.IsExistingMatchingCard(Card.IsNegatableMonster, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
    end
    local opt = 0
    if Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil, e, tp) then opt = 1 end
    if Duel.IsExistingMatchingCard(Card.IsNegatableMonster, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) then opt = opt + 2 end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EFFECT)
    local sel = Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
    e:SetLabel(sel)
    if sel == 0 then
        e:SetCategory(CATEGORY_ATTACH)
        Duel.SetOperationInfo(0, CATEGORY_ATTACH, nil, 1, 0, LOCATION_GRAVE + LOCATION_MZONE)
    else
        e:SetCategory(CATEGORY_NEGATE)
        Duel.SetOperationInfo(0, CATEGORY_NEGATE, nil, 1, 0, LOCATION_MZONE)
    end
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local sel = e:GetLabel()
    if sel == 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
        local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)
        local tc = g:GetFirst()
        if tc then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
            local sg = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_GRAVE + LOCATION_MZONE, LOCATION_GRAVE + LOCATION_MZONE, 1, 1, nil)
            if #sg > 0 then
                Duel.Overlay(tc, sg)
            end
        end
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
        local g = Duel.SelectMatchingCard(tp, Card.IsNegatableMonster, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
        local tc = g:GetFirst()
        if tc then
            Duel.NegateRelatedChain(tc, RESET_TURN_SET)
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e1)
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end
