#!/bin/sh
cabal-dev clean && cabal-dev install && ./cabal-dev/bin/gymmemo
