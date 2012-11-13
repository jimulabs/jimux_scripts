#!/usr/bin/env bash

if [ "`ps -ALL | grep Xvfb | wc -l`" -gt "0" ]
then Xvfb :1 -screen 0 1024x768x24 &
fi

PWD = `pwd`
ECLIPSE_HOME="`find ${PWD} -name 'eclipse*' -type d | head -1`"
DISPLAY=:1 $ECLIPSE_HOME/eclipse -consolelog -application jimux.server -data jimux-workspace -console -noexit -clean
