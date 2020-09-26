#!/bin/bash
mkdir -p trial_SRU_1
mkdir -p trial_SRU_2
mkdir -p trial_SRU_3
mkdir -p trial_GRU_1
mkdir -p trial_GRU_2
mkdir -p trial_GRU_3

# nohup bash go_single.sh 1 SRU 0 > translation_log_sru1 2>&1
# mv translation_log_sru1 trial_SRU_1/
nohup bash go_single.sh 2 SRU 0 > translation_log_sru2 2>&1
mv translation_log_sru2 trial_SRU_2/
nohup bash go_single.sh 3 SRU 0 > translation_log_sru3 2>&1
mv translation_log_sru3 trial_SRU_3/

nohup bash go_single.sh 1 GRU 1 > translation_log_gru1 2>&1
mv translation_log_gru1 trial_GRU_1/
# nohup bash go_single.sh 2 GRU 1 > translation_log_gru2 2>&1
# mv translation_log_gru2 trial_GRU_2/
# nohup bash go_single.sh 3 GRU 1 > translation_log_gru3 2>&1
# mv translation_log_gru3 trial_GRU_3/

