(ns tradingfloor.model.logic.validation.offer
          (:require  [bouncer.core :as b]
                     [bouncer.validators :as v]
                     [tradingfloor.model.logic.validation.general :as vg]))

;--custom validators
(v/defvalidator valid-offer-name
         {:default-message-format
         "Offer name must contain at least 10 characters"}
         [name]
         (clojure.core/re-matches #"([A-Za-z0-9]){10,}" name))

;validation functions

(defn valid-offer? [offer]
    (b/validate offer
        [:offerHeader :name] valid-offer-name
        [:offerHeader :price] [[vg/valid-value-range 0 999999
               :message "Price must be in range from 0 to 999999!"]]
        [:offerIdentifier :userId]  v/positive
        :amount  v/positive
        :description [v/matches #"[A-z]{10,}"
           :message "Description must contain at least 10 characters!"]))

 ;;Offer to validate
;;  offerheader "name: " not null and chars > 10
;;              price not null
;;             "price".value not null and (p > 0 and p < 10^12)
;;             "price"."currency" not null
;;  amount >= 1
;; description: not null chars > 100
;; UserOfferRelation: userId > 0
;; UserOfferRelation: offerId >= 0
1)  (db/create-offer! offer)


(defn valid-price? [price]
    (b/validate price
       [:offerHeader :price] [[vg/valid-value-range 0 999999
              :message "Price must be in range from 0 to 999999!"]]))

(defn valid-offer-identifier? [offerIdentifier]
    (b/validate offerIdentifier
       [:offerIdentifier :id] [ v/positive  :message "Offer id must be positive!"]
       [:offerIdentifier :userId] [ v/positive :message "User id must be positive!"]))
