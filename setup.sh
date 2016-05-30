#!/bin/bash

sed -i '/database: data_collector_test/ i\  host: postgres' config/database.yml
