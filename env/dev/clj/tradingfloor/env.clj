(ns tradingfloor.env
  (:require [selmer.parser :as parser]
            [clojure.tools.logging :as log]
            [tradingfloor.dev-middleware :refer [wrap-dev]]))

(def defaults
  {:init
   (fn []
     (parser/cache-off!)
     (log/info "\n-=[tradingfloor started successfully using the development profile]=-"))
   :stop
   (fn []
     (log/info "\n-=[tradingfloor has shut down successfully]=-"))
   :middleware wrap-dev})
