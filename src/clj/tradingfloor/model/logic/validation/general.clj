(ns tradingfloor.model.logic.validation.general
                (:require  [bouncer.core :as b]
                           [bouncer.validators :as v]))


;--custom validation functions

(v/defvalidator valid-range
       {:default-message-format  "Wrong range format!"}
       [range]
       (let [from {:from range}
             to   {:to range}]
       (and (and (> to from) (> to 0)) (> from 0))))

(v/defvalidator valid-value-range
          {:default-message-format
              "Value doesn't passes into range!" }
        [value minV maxV]
        (and (>= maxV value) (<= minV value)))

;-- validators
(defn valid-range? [from to]
    (b/validate {:range {:from from :to to}}
        :range valid-range ))

(defn valid-id?
      [id]
      (b/validate {:id id}
           :id v/positive "Id must be a positive number."))

;:message "%s must be a positive value."])
