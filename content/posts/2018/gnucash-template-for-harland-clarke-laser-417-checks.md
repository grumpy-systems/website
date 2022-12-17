---
title: "GNUCash Template for Harland Clarke Laser 417 Checks"
date: 2018-07-31
tags: ["random"]
---

So this is kinda random, but I needed a template to make these checks work with
GnuCash.  So if some other lazy soul wants to use it, here it is :)

```text
[Top]
Guid = c226b43c-1e06-417d-a191-e3e78a789341
Title = Harland Clarke Laser 417 Checks

[Check Positions]
Height = 250.0
Names = Top;Middle;Bottom

[Check Items]
Type_1 = PAYEE
Coords_1 = 75.0;95.0

Type_2 = AMOUNT_NUMBER
Coords_2 = 500.0;102.0

Type_3 = AMOUNT_WORDS
Coords_3 = 75.0;120.0;

Type_4 = ADDRESS
Coords_4 = 75.0;190.0

Type_5 = MEMO
Coords_5 = 60.0;200.0
```

To make it work, copy that into file called `laser417.chk` and drop it in
`~/.gnucash/checks`.
