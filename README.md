# Gsuite to local postfix forwarding

## Test setup

Created a new user account for the postfix server in Gsuite and added some lists as email aliases to the account.

For example, user accout lists@example.com with aliases list-foo@example.com and list-bar@example.com.

## Authentication

Fetchmail cannot out of the box do OAuth 2 authentication so one will have to enable "Insecure application" (e.g. password auth).
Since the organization used for testing had SSO enabled (onprem identity provider, no Google auth) there were possibly some extra
steps.

First attempt was to enable Insecure applications and create an application password. This didn't work. Running fetchmail with `-v`
showed the following error:
```
fetchmail: IMAP< * NO [WEBALERT https://accounts.google.com/signin/continue?sarp=1&scc=1&plt=...] Web login required.
fetchmail: IMAP< A0002 NO [ALERT] Please log in via your web browser: https://support.google.com/mail/accounts/answer/78754 (Failure)
fetchmail: Authorization failure on lists@example.com@imap.gmail.com
```

Following the link in the WEBALERT message authenticated the user using the SSO provider and wanted to set a new password for the
acount (note that normally the account is authenticated against the SSO  provider, not Google themselves). After setting a 
new password for the account and then recreating the app password, fetchmail was able to authenticate succesfully.

## Fetchmail

The configuration for fetchmail is fairly simple: it has a server that it polls and a destination it sends received messages to.
In this case we are forwarding messages via SMTP to localhost:25, where postfix is running.

## Postfix

Postfix is largely untouched by this demo and will attempt to cause a mail loop by resending the email towards gsuite.
This demo uses postfix 3.5 from gh repo to get logging to stdout, in order to remove the need for syslog
in the demo setup

## Demo
```
podman build -t fetch-gsuite .
podman run --rm -ti --name fetch-gsuite \
    -v $PWD/fetchmailrc:/etc/fetchmailrc -v $PWD/main.cf:/etc/postfix/main.cf -v $PWD/master.cf:/etc/postfix/master.cf \
    fetch-gsuite postfix start-fg
podman exec -ti fetch-gsuite fetchmail -v -f /etc/fetchmailrc
```
