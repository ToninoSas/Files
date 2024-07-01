-- DOC
local s, id = GetID()

-- Dichiarazione della carta
function s.initial_effect(c)
    -- Effetto XYZ
    -- Xyz.AddProcedure(c, nil, 4, 2) EDO PRO
    -- TODO 2+ monsters
    aux.AddXyzProcedure(c,nil,4,2, nil, nil, 99)
    
    local effectActivated = 0

    -- gain 1000lp
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(
        function(e, tp, eg, ep, ev, re, r, rp)
            return effectActivated == 0 
        end)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.cost)
    e1:SetOperation(
        function (e, tp, eg, ep, ev, re, r, rp)
            Duel.Recover(tp, 1000, REASON_EFFECT)
            effectActivated = effectActivated + 1
        end)
    c:RegisterEffect(e1)

    -- Effetto di negazione rapida
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(
        function (e,tp,eg,ep,ev,re,r,rp)
	        return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and effectActivated == 0
        end)
    e2:SetCost(s.cost)
    e2:SetTarget(s.negateTarget)
    e2:SetOperation(
        function (e, tp, eg, ep, ev, re, r, rp)
            Duel.NegateActivation(ev)
            effectActivated = effectActivated + 1
        end
    )
    c:RegisterEffect(e2)

    -- Reimposta i contatori alla fine del tuo turno
    local resetCounters = Effect.CreateEffect(c)
    resetCounters:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    resetCounters:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    resetCounters:SetCode(EVENT_TURN_END)
    resetCounters:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        effectActivated = 0  -- Reimposta i contatori degli effetti
    end)
    Duel.RegisterEffect(resetCounters, Duel.GetTurnPlayer())
end


-- Costo per staccare un materiale XYZ
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end


-- Target per l'effetto di negazione rapida
function s.negateTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
