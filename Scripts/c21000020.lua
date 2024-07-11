-- Sventu, il Guerriero S.A.F.
-- di EDOpro di User
-- Mostro Link OSCURITÀ [Effetti: Giù / Destra]
-- ATK ??? / LINK 2

-- Materiali richiesti: 2 mostri "S.A.F."
-- Quando questa carta viene Evocata in una Zona Mostri Extra, puoi Evocare Specialmente fino a 2 mostri "S.A.F." dalla tua mano o Cimitero nelle zone puntate da questa carta, ma i loro effetti sono annullati, inoltre distruggili durante la End Phase.
-- Quando questa carta viene mandata al Cimitero, puoi invece bandirla; se lo fai, aggiungi 1 "Aurora, la Combattente S.A.F." dal tuo Deck o Cimitero alla tua mano. Puoi attivare ogni effetto di "Sventu, il Guerriero S.A.F." una sola volta per turno.

-- Sventu, il guerriero S.A.F.
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon

    aux.AddLinkProcedure(c,s.matfilter,2,2)

    -- Link.AddProcedure(c,s.matfilter,2,2) EDOPRO
    c:EnableReviveLimit()

    -- Special Summon SAF monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Add Aurora, la combattente S.A.F. from Deck or GY to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0x81c,lc,sumtype,tp)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.spfilter(c,e,tp,zone)
    return c:IsSetCard(0x81c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local zone=e:GetHandler():GetLinkedZone(tp)
        return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,zone)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local zone=c:GetLinkedZone(tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,zone)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,2,nil)
        for sc in aux.Next(sg) do
            if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP,zone) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                sc:RegisterEffect(e1,true)
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                sc:RegisterEffect(e2,true)
                -- Destroy during End Phase
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
                e3:SetCode(EVENT_PHASE+PHASE_END)
                e3:SetCountLimit(1)
                e3:SetRange(LOCATION_MZONE)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                e3:SetOperation(s.desop)
                sc:RegisterEffect(e3)
            end
        end
        Duel.SpecialSummonComplete()
    end
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE)
end

function s.thfilter(c)
    return c:IsCode(21000008) and (c:IsAbleToHand() or c:IsLocation(LOCATION_GRAVE))
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToRemove() and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, e:GetHandler(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Remove(c, POS_FACEUP, REASON_EFFECT) ~= 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
        if g:GetCount() > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end