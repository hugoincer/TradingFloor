;; WARNING
;; The profiles.clj file is used for local environment variables, such as database credentials.
;; This file is listed in .gitignore and will be excluded from version control by Git.

{:profiles/dev  {:env {:database-url "postgresql://localhost/tradingfloor_dev?user=flooruser&password=12345678"}}
 :profiles/test {:env {:database-url "postgresql://localhost/tradingfloor_test?user=flooruser&password=12345678"}}}
