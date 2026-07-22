# Architecture and mapping to the source repository

The source repository separates the multiplier into these major combinational blocks:

- `gen_u16`: generate sixteen aligned 32-bit partial-product rows
- `wallace_reduce_16to11`
- `wallace_reduce_11to8`
- `wallace_reduce_8to6`
- `wallace_reduce_6to4`
- `wallace_reduce_4to3`
- `wallace_reduce_3to2`
- `brent_kung_adder_32`: final carry-propagate adder

This package retains the same arithmetic decomposition and adds registers at the natural boundaries:

```text
[a,b] -> PP + 16->11->8->6 -> REG -> 6->4->3->2 -> REG -> BK32 -> REG -> product
```

The combinational source modules use synthesizable behavioral equations at leaf level and explicit hierarchy at the reduction level. The top module is the only sequential datapath module.

## Pipeline behavior

- A valid transaction may be presented every clock.
- Bubbles propagate using `in_valid`, `stage1_valid_q`, `stage2_valid_q`, and `out_valid`.
- Datapath registers hold their previous value during bubbles to avoid unnecessary switching.
- `product` and `overflow_error` are qualified by `out_valid`.
- There is no ready/backpressure signal.

## Overflow interpretation

For legal unsigned 16x16 multiplication, the mathematical result always fits in 32 bits. Therefore all compressor overflow bits and the final adder carry-out must remain zero. `overflow_error` is retained as a datapath-integrity indicator rather than an arithmetic overflow result.
