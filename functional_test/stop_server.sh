#!/bin/bash

PID=$(lsof -i :3000 -F p | grep -E "p[0-9]+" | grep -Eo "[0-9]+")

kill -s INT "$PID"
