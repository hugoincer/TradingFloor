(ns tradingfloor.env
  (:require [clojure.tools.logging :as log]))

(def defaults
  {:init
   (fn []
     (log/info "\n-=[tradingfloor started successfully]=-"))
   :stop
   (fn []
     (log/info "\n-=[tradingfloor has shut down successfully]=-"))
   :middleware identity})
