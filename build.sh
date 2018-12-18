#!/bin/sh
erl -make || exit 1
cp src/pharo_erlang_bridge.app.src ebin/pharo_erlang_bridge.app || exit 1

