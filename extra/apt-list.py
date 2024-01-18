#!/usr/bin/python3

import apt

cache = apt.cache.Cache()
for package in cache:
    if package.is_installed and package.candidate.priority not in (
        "required",
        "important",
    ):
        print(package.name, end=" ")
print()
