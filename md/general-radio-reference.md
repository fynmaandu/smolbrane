---
title: General Radio Reference
subtitle: Frequency Information for United States Radio
author: jtriley2p
lang: en
toc-title: Contents
license: AGPL-3.0
---

## Introduction

The following document contains general information about frequency allocations
in the United States which does not require licenses.

All people, regardless of license, are authorized to receive signals from any
frequency, however, unlicensed transmissions are limited to the
[Civilian Bands](#cb),
[Family Radio Service, and General Mobile Radio Service](#frs-and-gmrs)
frequencies.

## National Calling Frequencies

The following are national frequencies to coordinate and find other operators,
generally the common courtesy is to move to another frequency after establishing
contact.

fm simplex over 2 meter band: 146.520 MHz

fm simplex over 0.7 meter band: 446.000 MHz

## NOAA Weather Radio Frequencies

National Oceanic and Atmospheric Administration (NOAA) transmits audio weather
data on one of the following frequencies all across the United States.

| Frequency   |
| ----------- |
| 162.400 MHz |
| 162.425 MHz |
| 162.450 MHz |
| 162.475 MHz |
| 162.500 MHz |
| 162.525 MHz |
| 162.550 MHz |

## FRS and GMRS

Family Radio Service (FRS) and General Mobile Radio Service (GMRS) refer to
frequencies on which civilians may transmit and receive with no special
licensing, provided each meets the transmission power restriction.

| Channel | Frequency    | FRS Max Power | GMRS Max Power |
| ------- | ------------ | ------------- | -------------- |
| 01      | 462.5625 MHz | <= 2.0 W      | <= 5.0 W       |
| 02      | 462.5875 MHz | <= 2.0 W      | <= 5.0 W       |
| 03      | 462.6125 MHz | <= 2.0 W      | <= 5.0 W       |
| 04      | 462.6375 MHz | <= 2.0 W      | <= 5.0 W       |
| 05      | 462.6625 MHz | <= 2.0 W      | <= 5.0 W       |
| 06      | 462.6875 MHz | <= 2.0 W      | <= 5.0 W       |
| 07      | 462.7125 MHz | <= 2.0 W      | <= 5.0 W       |
| 08      | 467.5625 MHz | <= 0.5 W      | <= 0.5 W       |
| 09      | 467.5875 MHz | <= 0.5 W      | <= 0.5 W       |
| 10      | 467.6125 MHz | <= 0.5 W      | <= 0.5 W       |
| 11      | 467.6375 MHz | <= 0.5 W      | <= 0.5 W       |
| 12      | 467.6625 MHz | <= 0.5 W      | <= 0.5 W       |
| 13      | 467.6875 MHz | <= 0.5 W      | <= 0.5 W       |
| 14      | 467.7125 MHz | <= 0.5 W      | <= 0.5 W       |
| 15      | 462.5500 MHz | <= 2.0 W      | <= 5.0 W       |
| 16      | 462.5750 MHz | <= 2.0 W      | <= 5.0 W       |
| 17      | 462.6000 MHz | <= 2.0 W      | <= 5.0 W       |
| 18      | 462.6250 MHz | <= 2.0 W      | <= 5.0 W       |
| 19      | 462.6500 MHz | <= 2.0 W      | <= 5.0 W       |
| 20      | 462.6750 MHz | <= 2.0 W      | <= 5.0 W       |
| 21      | 462.7000 MHz | <= 2.0 W      | <= 5.0 W       |
| 22      | 462.7250 MHz | <= 2.0 W      | <= 5.0 W       |

### GMRS Frequencies and CTCSS Codes

Channels above 22 are not real "channels", they're reused GMRS channels with
Continuous Tone Coded Squelch System (CTCSS) codes for multiplexing.

The CTCSS codes are sub-audible tones added to a transmission such that radios
can mute received signals which contain undesired CTCSS codes.

> Note: A radio tuned to 462.5625MHz with no CTCSS code set will play signals
> received from channel 1 and "channels" 23 and 42. However, since "channels" 23
> and 42 have CTCSS codes, the radio transmitting without a CTCSS code can only
> be heard on channel 1 (as this includes no CTCSS code).

| "Channel" | Underlying Channel | Frequency    | CTCSS Code | CTCSS Frequency |
| --------- | ------------------ | ------------ | ---------- | --------------- |
| 01        | 01                 | 462.5625 MHz | OFF        | OFF             |
| 02        | 02                 | 462.5875 MHz | OFF        | OFF             |
| 03        | 03                 | 462.6125 MHz | OFF        | OFF             |
| 04        | 04                 | 462.6375 MHz | OFF        | OFF             |
| 05        | 05                 | 462.6625 MHz | OFF        | OFF             |
| 06        | 06                 | 462.6875 MHz | OFF        | OFF             |
| 07        | 07                 | 462.7125 MHz | OFF        | OFF             |
| 08        | 08                 | 467.5625 MHz | OFF        | OFF             |
| 09        | 09                 | 467.5875 MHz | OFF        | OFF             |
| 10        | 10                 | 467.6125 MHz | OFF        | OFF             |
| 11        | 11                 | 467.6375 MHz | OFF        | OFF             |
| 12        | 12                 | 467.6625 MHz | OFF        | OFF             |
| 13        | 13                 | 467.6875 MHz | OFF        | OFF             |
| 14        | 14                 | 467.7125 MHz | OFF        | OFF             |
| 15        | 15                 | 462.5500 MHz | OFF        | OFF             |
| 16        | 16                 | 462.5750 MHz | OFF        | OFF             |
| 17        | 17                 | 462.6000 MHz | OFF        | OFF             |
| 18        | 18                 | 462.6250 MHz | OFF        | OFF             |
| 19        | 19                 | 462.6500 MHz | OFF        | OFF             |
| 20        | 20                 | 462.6750 MHz | OFF        | OFF             |
| 21        | 21                 | 462.7000 MHz | OFF        | OFF             |
| 22        | 22                 | 462.7250 MHz | OFF        | OFF             |
| 23        | 1                  | 462.5625 MHz | 38         | 250.3 Hz        |
| 24        | 3                  | 462.6125 MHz | 35         | 225.7 Hz        |
| 25        | 5                  | 462.6625 MHz | 32         | 203.5 Hz        |
| 26        | 7                  | 462.7125 MHz | 29         | 179.9 Hz        |
| 27        | 15                 | 462.5500 MHz | 26         | 162.2 Hz        |
| 28        | 17                 | 462.6000 MHz | 23         | 146.2 Hz        |
| 29        | 19                 | 462.6500 MHz | 20         | 131.8 Hz        |
| 30        | 21                 | 462.7000 MHz | 17         | 118.8 Hz        |
| 31        | 2                  | 462.5875 MHz | 1          | 67.0 Hz         |
| 32        | 4                  | 462.6375 MHz | 4          | 77.0 Hz         |
| 33        | 6                  | 462.6875 MHz | 7          | 85.4 Hz         |
| 34        | 8                  | 467.5625 MHz | 10         | 94.8 Hz         |
| 35        | 10                 | 467.6125 MHz | 13         | 103.5 Hz        |
| 36        | 12                 | 467.6625 MHz | 16         | 114.8 Hz        |
| 37        | 14                 | 467.7125 MHz | 19         | 127.3 Hz        |
| 38        | 16                 | 462.5750 MHz | 22         | 141.3 Hz        |
| 39        | 18                 | 462.6250 MHz | 25         | 156.7 Hz        |
| 40        | 20                 | 462.6750 MHz | 28         | 173.8 Hz        |
| 41        | 22                 | 462.7250 MHz | 31         | 192.8 Hz        |
| 42        | 1                  | 462.5625 MHz | 14         | 107.2 Hz        |
| 43        | 3                  | 462.6125 MHz | 11         | 97.4 Hz         |
| 44        | 5                  | 462.6625 MHz | 8          | 88.5 Hz         |
| 45        | 7                  | 462.7125 MHz | 5          | 79.7 Hz         |
| 46        | 15                 | 462.5500 MHz | 2          | 71.9 Hz         |
| 47        | 17                 | 462.6000 MHz | 37         | 241.8 Hz        |
| 48        | 19                 | 462.6500 MHz | 34         | 218.1 Hz        |
| 49        | 21                 | 462.7000 MHz | 31         | 192.8 Hz        |
| 50        | 2                  | 462.5875 MHz | 2          | 71.9 Hz         |
| 51        | 4                  | 462.6375 MHz | 5          | 79.7 Hz         |
| 52        | 6                  | 462.6875 MHz | 8          | 88.5 Hz         |
| 53        | 8                  | 467.5625 MHz | 11         | 97.4 Hz         |
| 54        | 10                 | 467.6125 MHz | 14         | 107.2 Hz        |
| 55        | 12                 | 467.6625 MHz | 17         | 118.8 Hz        |
| 56        | 14                 | 467.7125 MHz | 20         | 131.8 Hz        |
| 57        | 16                 | 462.5750 MHz | 23         | 146.2 Hz        |
| 58        | 18                 | 462.6250 MHz | 26         | 162.2 Hz        |
| 59        | 20                 | 462.6750 MHz | 29         | 179.9 Hz        |
| 60        | 22                 | 462.7250 MHz | 32         | 203.5 Hz        |

## CB

Civilian Band (CB) frequencies are much lower.

| Channel | Frequency  | General Purpose                   |
| ------- | ---------- | --------------------------------- |
| 01      | 26.965 MHz |                                   |
| 02      | 26.975 MHz |                                   |
| 03      | 26.985 MHz |                                   |
| 04      | 27.005 MHz | Offroading                        |
| 05      | 27.015 MHz |                                   |
| 06      | 27.025 MHz | "Super Bowl" channel (Not NFL?)   |
| 07      | 27.035 MHz |                                   |
| 08      | 27.055 MHz |                                   |
| 09      | 27.065 MHz | Emergencies only.                 |
| 10      | 27.075 MHz | Truckers on regional roads        |
| 11      | 27.085 MHz |                                   |
| 12      | 27.105 MHz |                                   |
| 13      | 27.115 MHz | Marine and recreational vehicles  |
| 14      | 27.125 MHz | Vintage walkie-talkies            |
| 15      | 27.135 MHz |                                   |
| 16      | 27.155 MHz | Offroading                        |
| 17      | 27.165 MHz | Truckers traveling north or south |
| 18      | 27.175 MHz |                                   |
| 19      | 27.185 MHz | Truckers traveling east or west   |
| 20      | 27.205 MHz |                                   |
| 21      | 27.215 MHz |                                   |
| 22      | 27.225 MHz |                                   |
| 23      | 27.235 MHz |                                   |
| 24      | 27.245 MHz |                                   |
| 25      | 27.255 MHz |                                   |
| 26      | 27.265 MHz |                                   |
| 27      | 27.275 MHz |                                   |
| 28      | 27.285 MHz |                                   |
| 29      | 27.295 MHz |                                   |
| 30      | 27.305 MHz |                                   |
| 31      | 27.315 MHz |                                   |
| 32      | 27.325 MHz |                                   |
| 33      | 27.335 MHz |                                   |
| 34      | 27.345 MHz |                                   |
| 35      | 27.355 MHz |                                   |
| 36      | 27.365 MHz |                                   |
| 37      | 27.375 MHz |                                   |
| 38      | 27.385 MHz | SSB calling                       |
| 39      | 27.395 MHz |                                   |
| 40      | 27.405 MHz |                                   |
