(ns tradingfloor.auth
  (:require [reagent.core :as r]
            [reagent.session :as session]
            [tradingfloor.ajax :refer [command-ajax]]))


(defn input-form [id value label protected]
 [:div
    [:label.inputstyle label ":"] [:br]
    [:input.inputstyle  {:id id :type (if protected "password" "text")
              :value @value
              :on-change #(reset! value (-> % .-target .-value))} ] [:br]])


(defn loginform [loggedin]
 (let [email (r/atom "")
       password (r/atom "")]
   (fn []
     [:div.loginstyle.bordered  
       [input-form "email" email "Your email" false]
       [input-form "password" password "Your password" true][:br]
       [:input.inputstyle
                 {:id "login" :type "button" :value  "Login"
                  :on-click #(command-ajax "authroute" "login"
                     {:email @email :password @password}
                     (fn [resp args]
                         (let [email (args 0)
                               password (args 1)
                               loggedin (args 2)
                               logres (:loggedin resp)
                               error (:error resp)]
                               (reset! password "")

                             (if (nil? error )
                              (if logres
                                  (do

                                     (reset! email "")
                                     (reset! loggedin logres)
                                     (js/alert "You've logged!" ))

                                     (js/alert "Wrong password!" ))

                               (js/alert (str "Error: " error )))))
                     [email password loggedin]
                  )}] [:br]]
)))





(defn regform []
  [:div  {:style {:position "relative" :left "30%"}}

    [:label "Authentication data:"] [:br][:br]

    [:label "User name:"] [:br]
    [:input  {:id "name" :type "text"} ] [:br]
    [:label "Password:"] [:br]
    [:input  {:id "password" :type "password"}] [:br] [:br]

    [:label "Your personal data:"] [:br][:br]

    [:label "First name:"] [:br]
    [:input  {:id "firstName" :type "text"} ] [:br]

    [:label "Patronymic:"] [:br]
    [:input  {:id "patronymic" :type "text"} ] [:br]

    [:label "Last name:"] [:br]
    [:input  {:id "lastName" :type "text"} ] [:br]

    [:label "Your contants data:"] [:br]
    [:textarea {:rows 10 :cols 80 :id "contacts"} ] [:br]

    [:input  {:id "login" :type "button" :value  "Register"}] [:br]
  ])
