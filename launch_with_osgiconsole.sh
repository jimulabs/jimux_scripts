#!/usr/bin/env bash

# TODO download jimu plugins
PWD = `pwd`
ECLIPSE_HOME="`find ${PWD} -name 'eclipse*' -type d | head -1`"
DISPLAY=:1 $ECLIPSE_HOME/eclipse -consolelog -application jimux.server -data jimux-workspace -console -noexit -clean
