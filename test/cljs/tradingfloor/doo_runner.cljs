(ns tradingfloor.doo-runner
  (:require [doo.runner :refer-macros [doo-tests]]
            [tradingfloor.core-test]))

(doo-tests 'tradingfloor.core-test)

