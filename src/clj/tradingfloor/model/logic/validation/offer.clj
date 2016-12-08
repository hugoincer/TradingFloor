(ns tradingfloor.model.validation.offer
          (:require  [bouncer.core :as b]
                     [bouncer.validators :as v]))

;--custom validators
(v/defvalidator valid-offer-name
         {:default-message-format
         "Offer name must contain at least 10 characters"}
         [name]
         (clojure.core/re-matches #"([A-Za-z0-9]){10,}" name))

(v/defvalidator valid-price
   {:default-message-format
       (str "Wrong price range before dot from 1-12, after 2")}
  [price]
    (and (clojure.core/re-matches #"([0-9]){1,12}[\,\.]([0-9]){2}"
             (str (:value price)) )
         (clojure.core/re-matches #"([A-Z]){3}" (:currency price) )))

;validation functions

(defn valid-offer? [offer]
    (b/validate offer
        [:offerHeader :name] valid-offer-name
        [:offerHeader :price] valid-price
        :amount [ v/positive ]
        :description [[v/matches #"[A-z]{10,}"]]))

(defn valid-price? [price]
    (b/validate price
       [:offerHeader :price] valid-price))
