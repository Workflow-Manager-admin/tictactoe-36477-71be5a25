#!/bin/bash
cd /home/kavia/workspace/code-generation/tictactoe-36477-71be5a25/tic_tac_toe
npm run lint
ESLINT_EXIT_CODE=$?
npm run build
BUILD_EXIT_CODE=$?
if [ $ESLINT_EXIT_CODE -ne 0 ] || [ $BUILD_EXIT_CODE -ne 0 ]; then
   exit 1
fi

