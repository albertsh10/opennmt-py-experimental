"""
 RNN tools
"""
import torch.nn as nn
import onmt.models


def rnn_factory(rnn_type, **kwargs):
    """ rnn factory, Use pytorch version when available. """
    no_pack_padded_seq = False
    if rnn_type == "SRU":
        # SRU doesn't support PackedSequence.
        no_pack_padded_seq = True
        rnn = onmt.models.sru.SRU(**kwargs)
    else:
        rnn = getattr(nn, rnn_type)(**kwargs)
    import inspect
    print(inspect.getsourcefiles(rnn))
    assert(0)
    return rnn, no_pack_padded_seq
