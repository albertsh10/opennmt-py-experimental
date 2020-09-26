#!/bin/bash
# export CUDA_VISIBLE_DEVICES=1,2,3,4 

rm -rf ckpt
rm -rf ckpt2
mkdir -p data
mkdir -p ckpt
mkdir -p ckpt2
# mkdir -p data/multi30k
# wget http://www.quest.dcs.shef.ac.uk/wmt16_files_mmt/training.tar.gz &&  tar -xf training.tar.gz -C data/multi30k && rm training.tar.gz
# wget http://www.quest.dcs.shef.ac.uk/wmt16_files_mmt/validation.tar.gz && tar -xf validation.tar.gz -C data/multi30k && rm validation.tar.gz
# wget http://www.quest.dcs.shef.ac.uk/wmt17_files_mmt/mmt_task1_test2016.tar.gz && tar -xf mmt_task1_test2016.tar.gz -C data/multi30k && rm mmt_task1_test2016.tar.gz
# 
# for l in en de; do for f in data/multi30k/*.$l; do if [[ "$f" != *"test"* ]]; then sed -i "$ d" $f; fi;  done; done
# for l in en de; do for f in data/multi30k/*.$l; do perl tools/tokenizer.perl -a -no-escape -l $l -q  < $f > $f.atok; done; done
# onmt_preprocess -train_src data/multi30k/train.en.atok -train_tgt data/multi30k/train.de.atok -valid_src data/multi30k/val.en.atok -valid_tgt data/multi30k/val.de.atok -save_data data/multi30k.atok.low -lower
# 

_step=5000
ckpts="multi30k_model_step_"$_step".pt"

onmt_train -data data/multi30k.atok.low -save_model ./ckpt/multi30k_model -world_size 8 -gpu_ranks 0 1 2 3 4 5 6 7 -rnn_type $2 -input_feed $3 -train_steps $_step -start_decay_steps 500 -decay_steps 75 -learning_rate 1.0 -learning_rate_decay 0.9 -batch_size 256
onmt_translate -gpu 0 -model ./ckpt/$ckpts -src data/multi30k/test2016.en.atok -tgt data/multi30k/test2016.de.atok -replace_unk -verbose -output ./ckpt/multi30k.test.pred.atok
perl tools/multi-bleu.perl data/multi30k/test2016.de.atok < ./ckpt/multi30k.test.pred.atok
# 
onmt_train -data data/multi30k.atok.low -save_model ./ckpt2/multi30k_model -world_size 8 -reset_optim all -gpu_ranks 0 1 2 3 4 5 6 7 -rnn_type $2 -input_feed $3 -train_steps $_step -start_decay_steps 500 -decay_steps 75 -learning_rate 1.0 -learning_rate_decay 0.9 --retrain -batch_size 256 --train_from ./ckpt/$ckpts
onmt_translate -gpu 0 -model ./ckpt2/$ckpts -src data/multi30k/test2016.en.atok -tgt data/multi30k/test2016.de.atok -replace_unk -verbose -output ./ckpt2/multi30k.test.pred.atok
perl tools/multi-bleu.perl data/multi30k/test2016.de.atok < ./ckpt2/multi30k.test.pred.atok
# 
# mkdir -p trial_$2_$1
# mv ckpt/ trial_$2_$1/
# mv ckpt2/ trial_$2_$1/

