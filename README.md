# bitonic_network

## Algorith description

This algorith is called the merge-sort algorithm. It takes advantage of a bitonic sequence to sort random values.

### Bitonic network representation

In the figure, every node represents a comparison between two values. If bigger/equal, then the value switches lines. Otherwise, it continues in the same line.

![Alt text](/doc/diagram_bn.jpg)

### How to build a bitonic network?

A bitonic network is a sequence as the represented below, where the elements are ordered from the least to the greatest and then, the other way around:

![Alt text](/doc/diagram_bn0.jpg)

To sort a bitonic sequence into an ordered sequence, we follow an algorithm.

The algorithm is divided in several steps:

![Alt text](/doc/diagram_bn1.jpg)

![Alt text](/doc/diagram_bn2.jpg)

![Alt text](/doc/diagram_bn3.jpg)

When the number sequence is random, the goal is first construct a bitonic sequence and then apply the previous algorithm:

![Alt text](/doc/diagram_bn4.jpg)

![Alt text](/doc/diagram_bn5.jpg)

![Alt text](/doc/diagram_bn6.jpg)

## RTL Schematic

![Alt text](/doc/diagram_rtl.jpg)