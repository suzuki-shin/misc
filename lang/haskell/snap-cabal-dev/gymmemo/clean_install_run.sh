#!/bin/sh
cabal-dev clean && cabal-dev install -fdevelopment && ./cabal-dev/bin/gymmemo
