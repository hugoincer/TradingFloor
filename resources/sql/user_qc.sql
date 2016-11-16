--- COMMANDS DEFINITIONS ---

-- :name create-user! :<! :n
-- :doc Creates new user.
SELECT public.create_user(:email, :password, :firstName, :patronymic,
                          :lastName, :contactData) AS result;

-- :name create-temp-auth! :! :1
-- :doc Creates temp authentication password and creates user if not exists.
SELECT public.create_temp_auth(:email, :oneTimePass, :expirationTime,
                               :firstName, :patronymic, :lastName, :contactData);

-- :name change-password! :! :n
-- :doc Changes the password of specified user.
UPDATE public.user
SET password = :password
WHERE id = :id
RETURNING NULL;

-- :name change-user-data! :! :n
-- :doc Changes user personal data.
UPDATE public."userData"
SET "firstName" = :firstName,
     patronymic = :patronymic,
    "lastName" = :lastName,
    "contactData" = :contactData
WHERE "userId" = :id
RETURNING 0;

-- :name add-like! :! :n
-- :doc Increments amount of likes for specified user.
UPDATE public."userData"
SET "likesAmount" = "likesAmount" + 1;
WHERE "userId" = (SELECT id FROM public.user WHERE email = :email)
RETURNING 0;

-- :name add-dislike! :! :n
-- :doc Increments amount of dislikes for specified user.
UPDATE public."userData"
SET "dislikesAmount" = "dislikesAmount" + 1;
WHERE "userId" = (SELECT id FROM public.user WHERE email = :email)
RETURNING 0;

-- :name update-last-login! :! :n
-- :doc Updates last login time for user.
UPDATE public."userData"
SET "lastLogin" = current_timestamp,
WHERE "userId" = :id
RETURNING 0;

--- QUERIES DEFINITIONS ---

-- :name get-auth-data :? :1
-- :doc Get user data for authenticity check.
SELECT (email, password, "expirationTime")
FROM public.user
WHERE id = :id;

-- :name get-auth-ones :? :1
-- :doc Get user data for temporary authenticity check.
SELECT (email, "oneTimePass", "expirationTime")
FROM public.user
WHERE id = :id;

-- :name get-data :? :1
-- :doc Get full user data.
SELECT ("firstName", patronymic, "lastName", "contactData",
        "lastLogin", "likesAmount", "dislikesAmount")
FROM public."userData"
WHERE "userId" = :id;
