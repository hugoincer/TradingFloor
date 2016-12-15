(ns tradingfloor.offer
  (:require [reagent.core :as r]
            [reagent.session :as session]))

(defn offer-form []
  [:div

    [:label "Offer data:"] [:br][:br]

    [:label "Name:"] [:br]
    [:input  {:id "name" :type "text"} ] [:br]

    [:label "Price:"] [:br]
    [:div
       [:label "Value:"] [:br]
       [:input  {:id "prvalue" :type "text"}] [:br]

       [:label "Currency:"] [:br]
       [:input  {:id "prcurrency" :type "text"}] [:br]
    ]

    [:label "Amount:"] [:br]
    [:input  {:id "firstName" :type "text"} ] [:br]

    [:label "description:"] [:br]
    [:textarea {:rows 10 :cols 80 :id "contacts"} ] [:br]

  ])



(def currencies (doall '({:id 1 :name "BYR"} {:id 2 :name "RUB"} {:id 3 :name "USD"})))

(defn currencies-select [currencies]
  [:select
    (for [item currencies]
       ^{:key (:id item)} [:option {:id (:id item)}(:name item)])])

 ;{:offerid 10 :name "Offer_1" :amount 15
 ;              :price {:value 592 :currency "BYR"}
 ;              :moddate "2016-12-13T23:25:49.780-00:00"
 ;              :viewed 0})]

; "Price: " [:input {:type "text" :value (:value price) }]
 ;   "Currency: " (currencies-select currencies)
 ;   [:input {:type "button" :value "Apply"}] [:br]
 ;   "Last modification date: " (:moddate offer-header) [:br]
  ;  "Times viewed: " (:viewed offer-header) [:br]

(defn -j [resp key]
   (aget (clj->js resp) (clojure.core/name key)))

(defn offer-short [offer-header]
 (let [price (:price offer-header)]
  [:div {:style {:background-color "#F59C0E"}}
       "Name: " (:name offer-header ) [:br]
       "Price: " [:input {:type "text" :value (:value price) }]
       "Currency: " (currencies-select currencies)
        [:input {:type "button" :value "Apply"}] [:br]
       "Last modification date: " (:moddate offer-header) [:br]
       "Times viewed: " (:viewed offer-header) [:br]]
  ))


;   [[:hr]
;[:hr]]

(def testoffers '({:offerid 10, :name "Offer_1", :amount 15, :price {:value 592, :currency "BYR"}, :moddate "2016-12-13T23:25:49.780-00:00", :viewed 0}
{:offerid 11, :name "Offer_2", :amount 12, :price {:value 165, :currency "BYR"}, :moddate "2016-12-13T23:25:49.883-00:00", :viewed 0}
{:offerid 12, :name "Offer_3", :amount 9, :price {:value 711, :currency "BYR"}, :moddate  "2016-12-13T23:25:49.916-00:00", :viewed 0}
{:offerid 13, :name "Offer_4", :amount 19, :price {:value 613, :currency "BYR"}, :moddate  "2016-12-13T23:25:49.949-00:00", :viewed 0}
{:offerid 14, :name "Offer_5", :amount 10, :price {:value 601, :currency "BYR"}, :moddate  "2016-12-13T23:25:50.020-00:00", :viewed 0}
{:offerid 15, :name "Offer_6", :amount 10, :price {:value 236, :currency "BYR"}, :moddate  "2016-12-13T23:25:50.064-00:00", :viewed 0}
{:offerid 16, :name "Offer_7", :amount 3, :price {:value 452, :currency "BYR"}, :moddate "2016-12-13T23:25:50.106-00:00", :viewed 0}
{:offerid 17, :name "Offer_8", :amount 7, :price {:value 583, :currency "BYR"}, :moddate  "2016-12-13T23:25:50.149-00:00", :viewed 0}
{:offerid 18, :name "Offer_9", :amount 9, :price {:value 96, :currency "BYR"}, :moddate  "2016-12-13T23:25:50.198-00:00", :viewed 0}))
