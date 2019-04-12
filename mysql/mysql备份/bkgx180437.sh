#!/bin/bash

mysqldump -uroot -proot gx180437 | gzip > /home/backup/gx180437_$(date +%Y%m%d_%H%M%S).sql.gz
