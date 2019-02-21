#!/bin/bash
for i in `cat $1`; do host $i | grep "address\|NXDOMAIN"; done
