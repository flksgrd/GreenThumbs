# PlatformIO pre-script: workaround for OpenThread i ESP-IDF 5.5.
#
# ESP-IDF definerer OPENTHREAD_BUILD_DATETIME=" 2026-10-21 12:35:53 UTC"
# (med mellemrum). PlatformIO's espidf-builder (extract_defines) citerer
# værdien forkert, så shell'en splitter den, og instance_api.cpp fejler med
# "expected ',' or ';' before numeric constant".
#
# Vi erstatter værdien med en streng uden mellemrum, lige før kommando-
# linjen bygges. Alle build-miljøer klones fra env, så de arver rettelsen.
# Fjern scriptet når platform-espressif32 retter extract_defines().

Import("env")

from SCons.Defaults import _defines

BROKEN = "OPENTHREAD_BUILD_DATETIME"


def _fix(d):
    if isinstance(d, (tuple, list)) and len(d) == 2 and d[0] == BROKEN:
        stamp = str(d[1]).replace('"', "").strip().replace(" ", "_")
        return (BROKEN, '\\"%s\\"' % stamp)
    return d


def _defines_fixed(prefix, defs, suffix, env, *args, **kwargs):
    if defs and not isinstance(defs, (str, dict)):
        defs = [_fix(d) for d in defs]
    return _defines(prefix, defs, suffix, env, *args, **kwargs)


env["_defines"] = _defines_fixed
