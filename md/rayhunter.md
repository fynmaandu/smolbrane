---
title: The Rayhunter
subtitle: A deep dive into the EFF's stingray detection device.
author: jtriley2p
lang: en
toc-title: Contents
license: AGPL-3.0
---

- [Introduction](#introduction)
- [Enter: Rayhunter](#enter-rayhunter)
- [Analyzers](#analyzers)
  - [Connection Redirect 2G Downgrade](#connection-redirect-2g-downgrade)
  - [Priority 2G Downgrade Broadcast](#priority-2g-downgrade-broadcast)
  - [IMSI Requested](#imsi-requested)
  - [IMSI Provided](#imsi-provided)
  - [Null Cipher](#null-cipher)
- [Installation and Usage](#installation-and-usage)
  - [Installation](#installation)
  - [Usage](#usage)
    - [On WiFi](#on-wifi)
    - [On USB-C](#on-usb-c)
- [Conclusion](#conclusion)

## Introduction

<pre>

                \
    .        \    \
    │   \     |    |
    ┃    |    |    |                \
   ┌╀┐  /     |    |            \    \
   ├┼┤       /    /        \     |    |
   ├┼┤           /   ...    |    |    |      ╒══════╕
   ├┼┤               │││   /     |    |      │  :(  │╒══╕
┏━━┷┷┷━━┓           ┏┻┻┻┓       /    /       ╞══════╡│:(│
┃  GMS  ┃           ┃FBS┃           /        │≣≣≣≣≣≣│╘══╛
┗━━━━━━━┛           ┗━━━┛ ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈└──────┘ ┊
    ╰┈┈┈┈┈┈┈┈┈┈┈┈┈╳   ╰┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈╯

data link: "┈┈┈"

</pre>

Fake base stations (FBS), cell-site simulators (CSS), stingrays, dirtboxes, each of these target the
weaknesses in 2G and 3G protocols, either directly or by forcing downgrades from the more secure 4G
and 5G protocols. Known attacks by FBS devices include denial of service (DoS), wireless jamming,
capturing real-time location, capturing uniquely identifying data about the user device as well as
the user's subscription to a cell provider, and forcibly redirecting the target devices onto
malicious networks where the attacker can intercept SMS messages, calls, and internet traffic, 

These FBS's are sold from private corporations to law enforcement and state surveillance
agencies, though the increasing availability of software defined radios (SDR) and relevant software
has increasingly put this technology in the hands of hacking organizations. The private corporations
that sell this hardware do so strictly to law enforcement and intelligence agencies, never
researchers, as such, there are very few empirical, replicable studies of FBS technology. However,
heuristics are developed by known weaknesses in these protocols.

Also, the Electronic Frontier Foundation (EFF) maintains an open database aggregating public records
which show the various agencies and law enforcement organizations that have acquired this
technology. The open database is called the Atlas of Surveillance.

- [https://atlasofsurveillance.org](https://atlasofsurveillance.org)

## Enter: Rayhunter

Rayhunter is an AGPL-3.0 licensed, free and open source software project recently announced by the
EFF. At the time of writing, the Rayhunter software runs on the Orbic RC400L mobile hotspot. It
continuously reads the Qualcomm Mobile Diagnostic Logs (QMDL), sending each log to a collection of
analyzers, each targeting different heuristics that may detect the presence of an FBS. We'll take a
look at each of the analyzers in the following sections and toward the end we'll discuss how to set
up this software on the Orbic device.

## Analyzers

The analyzers are capable of reading "information elements" from the diagnostic logs and optionally
triggering an "event" containing some information about the event and a severity of "informational",
"low", "medium", or "high".

The recommended actions vary by level of severity as follows.

- `Informational`: No action necessary, can be hidden in the user settings.
- `Low`: If combined with a large number of other warnings, investigate.
- `Medium`: If combined with a few other warnings, investigate.
- `High`: Always investigate.

### Connection Redirect 2G Downgrade

The "Connection Redirect 2G Downgrade Analyzer" checks for a redirect from a rogue LTE (4G)
network to a rogue 2G network, which generally contains less security features than an LTE network,
enabling further exploitation.

This attack targets weaknesses in how cell towers engage in load-balancing, that is, when traffic on
a single cell tower is high but on another it is low, the high traffic cell tower will redirect the
user to the low traffic tower as a means to balance the network traffic. Since a tower only telling
a user "find a new network" would require the user to search through all the local towers,
increasing network traffic substantially, instead the towers are aware of each others' capacities
and sends the user a specific tower to connect to instead. The user device generally trust's what
the tower tells it.

Any 2G downgrade redirect triggers a high priority notification.

Source: ["Forcing a targeted LTE cellphone into an eavesdropping network": Lin Huang](https://archive.conference.hitb.org/hitbsecconf2016ams/sessions/forcing-a-targeted-lte-cellphone-into-an-eavesdropping-network/)

### Priority 2G Downgrade Broadcast

The "LTE SIB6 and SIB7 Downgrade Analyzer" checks for a 2G downgrade request over a rogue LTE
network with high priority. Functionally, the attack is similar to the network redirect, but rather
than reject from the first FBS and redirect to the second, instead an FBS broadcasts a "system
information block" (SIB) with a high priority such that the user device connects to its rogue 2G
network.

Any 2G priority messages trigger a high priority notification.

Source: ["Why We Cannot Win": Shinjo Park (PDF)](https://api-depositonce.tu-berlin.de/server/api/core/bitstreams/99520397-8b47-4ea4-acd6-2b17c9a78bd4/content)

### IMSI Requested

The "IMSI Requested Analyzer" checks for Non-Stratum Access (NAS) messages over LTE which request
the International Mobile Subscriber Identity (IMSI) from the target device. In this scenario, the
attacker sends an IMSI request to the target device to gain a unique identifier for the mobile
subscription. However, requesting the IMSI is a common operation in connecting to a new network, so
if the number of packets exchanged is below a given threshold, it may trigger a false positive.

If the IMSI request happens in the first few packets of the analysis, it is likely a false positive;
at the time of writing, an IMSI request within the first 150 packets will give a medium priority
notification, indicating this may be expected behavior, otherwise it will give a high priority
notification.

### IMSI Provided

The "IMSI Provided Analyzer" checks for IMSI identity responses to the cell network. This is similar
to the above "IMSI Requested Analyzer", but it checks explicitly if the user device returned the
IMSI.

All IMSI responses to the cell network trigger a high priority notification.

### Null Cipher

The "Null Cipher Analyzer" checks for connection reconfigurations or security-mode commands from an
LTE network to use the LTE "null cipher", that is an unencrypted option on LTE generally reserved
for testing or emergency calling purposes.

This takes advantage of the option to send LTE traffic unencrypted, though its integrity is still
verified. As such, SMS messages, calls, and websites visited may be exposed through the Null Cipher.

At the time of writing, the Null Cipher Analyzer is disabled as it gives false positives due to a
bug in an upstream software dependency.

## Installation and Usage

### Installation

To use the Rayhunter software with an Orbic RC400L mobile hotspot, we'll use the following commands
in a shell. Note that this assumes you are using a Linux or MacOS operating system because Windows
is an affront to God.

We use `curl` to download the release bundle. At the time of writing, `v0.2.7` is the latest version
so this is the version listed below. We use the `-LO` options where `L` signals to handle any
redirects to the actual file and `O` signals to place the downloaded data into a file matching that
in the link. Note that our file will be `./release.tar`.

```bash
curl -LO https://github.com/EFForg/rayhunter/releases/download/v0.2.7/release.tar
```

We use the `curl` command again to download the SHA-256 hash of the downloaded file. This is a means
to check the validity of the download in case of any in-transit data corruption. The downloaded hash
will be written to `./release.tar.sha256`.

```bash
curl -LO https://github.com/EFForg/rayhunter/releases/download/v0.2.7/release.tar.sha256
```

The contents of `./release.tar.sha256` should be similar to the following. Note that if you are
downloading a different release, the file content may be different.

```txt
5adbcf812175fec5995f190b9be2fa5283806435e36da089083402b932547599  release.tar
```

We can verify the integrity using the `sha256sum` command. This reads the `./release.tar.sha256`
file and checks the SHA-256 hash in it against its corresponding file. The following should print
"`release.tar: OK`" to the terminal. If not, start the process over.

```bash
sha256sum -c release.tar.sha256
```

Next we unpack the download with `tar` using the `-xf` flag where the `x` signals to extract the
data while `f <filename>` indicates which to extract. The following also removes the `.tar` archive
and its SHA-256 hash if the extraction is successful.

```bash
tar -xf release.tar && rm release.tar release.tar.sha256
```

From here we turn on the Orbic device and plug it into the computer with a USB-C cable.

Then we run the installation script.

```bash
./install.sh
```

Once this is finished, the Rayhunter should be running on the Orbic device and will automatically
start when turned on!

Updating to a new release can be done by simply running the above steps with the newest release
version in the future.

### Usage

Since it runs automatically after installation, there is nothing more to do to activate the device,
however, it does put together a report on a local website we can view from the browser. We can
access the website either by connecting a phone or computer to it over WiFi, or over a USB-C cable,
provided the Android Debug Bridge (`adb`) is installed on the computer.

#### On WiFi

To use over WiFi, connect the phone or computer to the device and visit the following in a web
browser. Note that HTTPS is not enabled at the time of writing, so the browser may give a warning of
unencrypted web traffic.

```txt
http://192.168.1.1:8080
```

#### On USB-C

To use over USB-C, use the `adb` command to forward the data to port 8080 on your device.

```bash
adb forward tcp:8080 tcp8080
```

Then visit `http://localhost:8080`.

## Conclusion

The Rayhunter is one of a few FBS detection solutions available. This software in particular parses
through Qualcomm Mobile Diagnostic Logs to find activity that appears to be that of an FBS. It is
important to note that this is a proof of concept at the time of writing and should not be used in
high-risk situations. That said, there is very little empirical data in the wild of FBS usage, as
such the development of technologies like Rayhunter depend on using known vulnerabilities in modern
cell networking protocols and using the data gathered to make adjustments in the future. The
Electronic Frontier Foundation has a Signal channel open to send any captured data by these
Rayhunter devices so that more large scale analysis can be conducted.

Until next time,
Peace.
