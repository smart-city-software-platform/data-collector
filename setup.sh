#!/bin/bash

sed -i '/database: data_collector_test/ i\  host: mysql' config/database.yml
