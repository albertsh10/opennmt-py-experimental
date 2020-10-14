#!/bin/bash
export CUDA_VISIBLE_DEVICES=7

rm -rf ckpt
mkdir -p data
mkdir -p ckpt
mkdir -p data/multi30k
# wget http://www.quest.dcs.shef.ac.uk/wmt16_files_mmt/training.tar.gz &&  tar -xf training.tar.gz -C data/multi30k && rm training.tar.gz
# wget http://www.quest.dcs.shef.ac.uk/wmt16_files_mmt/validation.tar.gz && tar -xf validation.tar.gz -C data/multi30k && rm validation.tar.gz
# wget http://www.quest.dcs.shef.ac.uk/wmt17_files_mmt/mmt_task1_test2016.tar.gz && tar -xf mmt_task1_test2016.tar.gz -C data/multi30k && rm mmt_task1_test2016.tar.gz
# 
# for l in en de; do for f in data/multi30k/*.$l; do if [[ "$f" != *"test"* ]]; then sed -i "$ d" $f; fi;  done; done
# for l in en de; do for f in data/multi30k/*.$l; do perl tools/tokenizer.perl -a -no-escape -l $l -q  < $f > $f.atok; done; done
# onmt_preprocess -train_src data/multi30k/train.en.atok -train_tgt data/multi30k/train.de.atok -valid_src data/multi30k/val.en.atok -valid_tgt data/multi30k/val.de.atok -save_data data/multi30k.atok.low -lower
# 

_step=20000
# _step=100
ckpts="multi30k_model_step_"$_step".pt"

cp ~/.local/lib/python3.7/site-packages/torch/nn/modules/rnn.py rnn_orig.py
cp rnn_patch.py ~/.local/lib/python3.7/site-packages/torch/nn/modules/rnn.py

onmt_train -data data/multi30k.atok.low -save_model ./ckpt/multi30k_model -world_size 1 -gpu_ranks 0 -rnn_type $2 -input_feed $3 -train_steps $_step -start_decay_steps 5000 -decay_steps 5000 -learning_rate 1.0 -learning_rate_decay 0.5 -batch_size 256
onmt_translate -gpu 0 -model ./ckpt/$ckpts -src data/multi30k/test2016.en.atok -tgt data/multi30k/test2016.de.atok -replace_unk -verbose -output ./ckpt/multi30k.test.pred.atok
perl tools/multi-bleu.perl data/multi30k/test2016.de.atok < ./ckpt/multi30k.test.pred.atok

cp rnn_orig.py ~/.local/lib/python3.7/site-packages/torch/nn/modules/rnn.py
