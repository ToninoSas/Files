-- Definizione della carta
-- 55 di mano
local s, id = GetID()

function s.initial_effect(c)
    -- Attivazione
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_NEGATE + CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    e1:SetCountLimit(1, id)
    c:RegisterEffect(e1)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    local at = Duel.GetAttacker()
    local d = Duel.GetAttackTarget()
    return d and d:IsFaceup() and d:IsSetCard(0x81c) and d:IsControler(tp)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, Duel.GetAttacker(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetChainLimit(aux.FALSE)
end

function s.filter(c,tp)
    return c:IsSetCard(0x81c) and c:IsType(TYPE_MONSTER)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateAttack() then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
        e1:SetProperty(EFFECT_FLAG_OATH)
        e1:SetTargetRange(0, LOCATION_MZONE)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
        
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
        if g:GetCount() > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end
