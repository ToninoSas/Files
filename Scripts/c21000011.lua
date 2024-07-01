-- pescatore di sassi.
local s, id = GetID()

function s.initial_effect(c)
    -- Synchro Summon
    -- aux.SynchroProcedure(c, s.tuner_filter, s.nontuner_filter, 1)
    aux.AddSynchroProcedure(c,nil,aux.NonTuner(s.sfilter),1, 1)

    -- Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(s.sfilter),1,99) EDO PRO
    c:EnableReviveLimit()

    --Must first be synchro summoned
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)

    -- Effetto: Rivela 3 carte
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DRAW + CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.sfilter(c)
    return c:IsAttribute(ATTRIBUTE_WATER)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 3) end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 3)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetDecktopGroup(tp, 3)
    if g:GetCount() == 0 then return end
    Duel.ConfirmCards(tp, g)
    Duel.ConfirmCards(1 - tp, g)

    local ct = g:FilterCount(Card.IsType, nil, TYPE_MONSTER)
    local atk = ct * 500
    if atk > 0 then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        c:RegisterEffect(e1)
    end

    local mt = g:FilterCount(Card.IsType, nil, TYPE_SPELL + TYPE_TRAP)
    if mt > 0 then
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_EXTRA_ATTACK)
        -- max un attacco extra
        if(mt>1) then
            e2:SetValue(1)
        else
            e2:SetValue(mt)
        end
        e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE)
        c:RegisterEffect(e2)
    end
    -- banish
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
end
