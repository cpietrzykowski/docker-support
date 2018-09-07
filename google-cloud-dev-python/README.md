# GCP Python Development Environment

This started as a containerization for app engine Python development and
testing. Both versions of Python are installed -- Python2 is required for the
SDK even if you're using Python3.

> [cloud.google.com](https://cloud.google.com/python/setup)

---

## NOTES

This is *not* a production container (for starters the cloud sdk is a a fairly
large layer). There is a "hack" that disables the origin and xsrf checks in the
dev_appserver provided by the cloud sdk.

If you want to persist your data for whatever reason in development
(fixtures/seed/etc.) the volume to pair is at /tmp/.appstorage.

## TODO

- either roll go and java into this container or create separate ones?
