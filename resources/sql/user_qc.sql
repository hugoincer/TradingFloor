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
UPDATE public.role
SET password = :password
WHERE id = :id
RETURNING NULL;

-- :name change-user-data! :! :n
-- :doc Changes user personal data.
UPDATE public."userData"
SET "firstName" = :firstName,
     patronymic = :patronymic,
    "lastName" = :lastName,
    "contacts" = :contacts
WHERE "userId" = :id
RETURNING 0;

-- :name add-like! :! :n
-- :doc Increments amount of likes for specified user.
UPDATE public."userData"
SET "likes" = "likes" + 1;
WHERE "userId" = (SELECT id FROM public.role WHERE email = :email)
RETURNING 0;

-- :name add-dislike! :! :n
-- :doc Increments amount of dislikes for specified user.
UPDATE public."userData"
SET "dislikes" = "dislikes" + 1;
WHERE "userId" = (SELECT id FROM public.role WHERE email = :email)
RETURNING 0;

-- :name update-last-login! :! :n
-- :doc Updates last login time for user.
UPDATE public."userData"
SET "lastLogin" = current_timestamp,
WHERE "userId" = :id
RETURNING 0;

-- :name change-photo! :! :n
-- :doc Updates user photo
UPDATE public."userData"
SET photo = :photo
WHERE "userId" = :id
RETURNING 0;

--- QUERIES DEFINITIONS ---

-- :name get-auth-data :? :1
-- :doc Get user data for authenticity check.
SELECT id, password
FROM public.role
WHERE email = :email;

-- :name get-auth-ones :? :1
-- :doc Get user data for temporary authenticity check.
SELECT email, "oneTimePass", "expirationTime"
FROM public.role
WHERE email = :email;

-- :name get-user-data :? :1
-- :doc Get full user data.
SELECT ("firstName", patronymic, "lastName", likes, dislikes, "lastLogin",
        "contacts")
FROM public."userData"
WHERE "userId" = :id;

-- :name get-user-photo :? :1
-- :doc Gets the user photo as BLOB.
SELECT photo FROM public."userData"
WHERE "userId" = :id
