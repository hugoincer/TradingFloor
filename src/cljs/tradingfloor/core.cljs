(ns tradingfloor.core
  (:require [reagent.core :as r]
            [reagent.session :as session]
            [secretary.core :as secretary :include-macros true]
            [goog.events :as events]
            [goog.history.EventType :as HistoryEventType]
            [markdown.core :refer [md->html]]
            [tradingfloor.ajax :refer [load-interceptors! command-ajax]]
            [ajax.core :refer [GET POST]]
            [tradingfloor.auth :as ta]
            [tradingfloor.offer :as tof])
  (:import goog.History))
;      [tradingfloor.offer :as tof])


(def displayed (r/atom "none"))
(def logedin (r/atom false))


(defn nav-link [id name displayed value]
  [:li.nav-item
   {:style {:color (if (= @displayed value) "black"  "white" )}}
   [:label {:id id
     :on-click #(reset! displayed (if (= @displayed value)
                                      "none" value))} name]])
(defn nav-logout [id name]
  [:li.nav-item
   {:style {:color "white" }}
   [:label {:id id } name]])


(defn navbar [loggedin]
   [:nav.navbar.navbar-dark.bg-primary
     [:div.collapse.navbar-toggleable-xs
       [:a.navbar-brand {:href "#/"} "tradingfloor"]
         [:ul.nav.navbar-nav
          (if (not @loggedin)
           [:div
               [nav-link "navlogin" "Login" displayed "login"]
               [nav-link "navregister" "Register" displayed "register"]]

           [nav-logout "navlogout" "Logout"])
        ]]])


(defn some-magic [message]
   [:input {:type "text" :value @message
            :on-change #(reset! message (-> % .-target .-value))}]
)


(defn my-ajax-func []
 (let [message (r/atom "Test message")
       val  (r/atom 1)]
 (fn []
  [:div
    [:label @message][:br]
    [:label @val][:br]
    [some-magic message][:br]
    [:input {:id "ajtest" :type "button" :value "Test Aj"
             :on-click #(command-ajax "command" "magic"
                {:user "magc" :password "1345"}
                (fn [resp args]
                    (js/alert resp))
                   ; (reset! message (:message resp)))
                [message val]
             )} ][:br]
  ])
))

(defn high-form []
 (let [loggedin (r/atom false)]
   (fn []
     [:div
       [navbar loggedin]
       (if (not @loggedin)
         [:div.bordered
            (cond
              (= @displayed "login") [ta/loginform loggedin]
              (= @displayed "register") [ta/regform])] )

      [my-ajax-func]
      [:div
       (for [item tof/testoffers]
         ^{:key (:offerid item)}
          [:div [:hr] [tof/offer-short item]])]]
 )
 )
)


;[nav-link "navlogin" "Login" displayedlog]
 ; [:button.navbar-toggler.hidden-sm-up
  ; {:on-click #(swap! collapsed? not)} "☰"]

(defn about-page []
  [:div.container
   [:div.row
    [:div.col-md-12
     "this is the story of tradingfloor... work in progress"]]])

(defn home-page []
  [:div.container
   (when-let [docs (session/get :docs)]
     [:div.row>div.col-sm-12
      [:div {:dangerouslySetInnerHTML
             {:__html (md->html docs)}}]])])

(def pages
  {:home #'home-page
   :about #'about-page})

(defn page []
  [(pages (session/get :page))])

;; -------------------------
;; Routes
(secretary/set-config! :prefix "#")

(secretary/defroute "/" []
  (session/put! :page :home))

(secretary/defroute "/about" []
  (session/put! :page :about))

;; -------------------------
;; History
;; must be called after routes have been defined
(defn hook-browser-navigation! []
  (doto (History.)
        (events/listen
          HistoryEventType/NAVIGATE
          (fn [event]
              (secretary/dispatch! (.-token event))))
        (.setEnabled true)))

;; -------------------------
;; Initialize app
(defn fetch-docs! []
  (GET (str js/context "/docs") {:handler #(session/put! :docs %)}))

(defn mount-components []
  (r/render [#'high-form] (.getElementById js/document "highform")))

(defn init! []
  (load-interceptors!)
  (fetch-docs!)
  (hook-browser-navigation!)
  (mount-components))
