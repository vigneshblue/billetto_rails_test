#!/usr/bin/env bash

set -o errexit

bundle install

bin/rails db:migrate

bin/rails billetto:sync_events