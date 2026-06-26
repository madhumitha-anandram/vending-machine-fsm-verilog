## What this project does

This project implements a coin-operated vending machine that accepts ₹5 and ₹10 coins and dispenses an item costing ₹15. Two versions are implemented: a basic version and an enhanced version with a timeout mechanism.

Coin encoding

| Input in[1:0] | Meaning |
| --- | --- |
| 2'b00 | No coin inserted |
| 2'b01 | ₹5 inserted |
| 2'b10 | ₹10 inserted |

States

| State | Meaning | Total deposited so far |
| --- | --- | --- |
| S0 | IDLE / reset | ₹0 |
| S1 | Partial payment | ₹5 |
| S2 | Partial payment | ₹10 |

When the total reaches ₹15, out goes HIGH (item dispensed) and the correct change is returned on change[1:0].

How the basic version works (vending_machine.v)

A Mealy FSM — outputs (out, change) depend on both the current state and the current input. All logic is in a single combinational always block driven by ps and in. The state register is a simple clocked block.

State transition table:

| State | Coin in | Next State | out | change |
| --- | --- | --- | --- | --- |
| S0 | ₹5 | S1 | 0 | ₹0 |
| S0 | ₹10 | S2 | 0 | ₹0 |
| S1 | ₹5 | S2 | 0 | ₹0 |
| S1 | ₹10 | S0 | 1 | ₹0 |
| S1 | none | S0 | 0 | ₹5 |
| S2 | ₹5 | S0 | 1 | ₹0 |
| S2 | ₹10 | S0 | 1 | ₹5 |
| S2 | none | S0 | 0 | ₹10 |

The timeout version (vending_machine_with_timeout.v)

The enhanced version adds a 4-bit counter that starts counting as soon as a coin is inserted. If no new coin arrives within 10 clock cycles, the machine resets to S0 and refunds whatever was deposited.

Key additions:

counter — 4-bit counter, resets on any coin input or on reset

timeout wire — goes HIGH when counter == 10

in_reg — the input in is registered (sampled on clock edge) to avoid combinational glitches

This version also separates the FSM into 3 clean always blocks: input register, counter, state register, and next-state/output logic — proper synthesizable style.

## File structure

vending_machine.v                   — Basic Mealy FSM

vending_machine_tb.v                — Tests all coin combinations and refund paths

vending_machine_with_timeout.v      — Enhanced version with 10-cycle timeout

vending_machine_with_timeout_tb.v   — Tests timeout refund and normal dispensing

