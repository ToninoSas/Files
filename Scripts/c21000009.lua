--Isaac, il guerriero S.A.F.
local s,id,o=GetID()
function c21000009.initial_effect(c)
	--piercing damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)

	--Gain 500 ATK until next Standby Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c21000009.atkop)
	e2:SetCondition(c21000009.atkcon)
	c:RegisterEffect(e2)
end

function c21000009.atkcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer() == tp and Duel.GetCurrentPhase() == PHASE_BATTLE
end


function c21000009.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		c:RegisterEffect(e1)
	end
end