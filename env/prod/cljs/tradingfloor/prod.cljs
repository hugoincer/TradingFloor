(ns tradingfloor.app
  (:require [tradingfloor.core :as core]))

;;ignore println statements in prod
(set! *print-fn* (fn [& _]))

(core/init!)
