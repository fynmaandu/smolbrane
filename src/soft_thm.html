<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="generator" content="pandoc" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
  <meta name="author" content="jtriley2p" />
  <title>The Rayhunter</title>
  <link rel="stylesheet" href="reset.css" />
  <link rel="stylesheet" href="index.css" />
</head>
<body>
<table class="header">
  <tr>
    <td colspan="2" rowspan="2" class="width-auto">
      <h1 class="title">The Rayhunter</h1>
      <span class="subtitle">A deep dive into the EFF’s stingray
detection device.</span>
    </td>
    <th>Version</th>
    <td class="width-min">v1.0.0</td>
  </tr>
  <tr>
    <th>Updated</th>
    <td class="width-min"><time style="white-space: pre;">2025-04-01</time></td>
  </tr>
  <tr>
    <th class="width-min">Author</th>
    <td class="width-auto"><a href=""><cite>jtriley2p</cite></a></td>
    <th class="width-min">License</th>
    <td>AGPL-3</td>
  </tr>
</table>
<ul class="incremental">
<li><a href="#introduction">Introduction</a></li>
<li><a href="#enter-rayhunter">Enter: Rayhunter</a></li>
<li><a href="#analyzers">Analyzers</a>
<ul class="incremental">
<li><a href="#connection-redirect-2g-downgrade">Connection Redirect 2G
Downgrade</a></li>
<li><a href="#priority-2g-downgrade-broadcast">Priority 2G Downgrade
Broadcast</a></li>
<li><a href="#imsi-requested">IMSI Requested</a></li>
<li><a href="#imsi-provided">IMSI Provided</a></li>
<li><a href="#null-cipher">Null Cipher</a></li>
</ul></li>
<li><a href="#installation-and-usage">Installation and Usage</a>
<ul class="incremental">
<li><a href="#installation">Installation</a></li>
<li><a href="#usage">Usage</a>
<ul class="incremental">
<li><a href="#on-wifi">On WiFi</a></li>
<li><a href="#on-usb-c">On USB-C</a></li>
</ul></li>
</ul></li>
<li><a href="#conclusion">Conclusion</a></li>
</ul>
<h2 id="introduction">Introduction</h2>
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
<p>Fake base stations (FBS), cell-site simulators (CSS), stingrays,
dirtboxes, each of these target the weaknesses in 2G and 3G protocols,
either directly or by forcing downgrades from the more secure 4G and 5G
protocols. Known attacks by FBS devices include denial of service (DoS),
wireless jamming, capturing real-time location, capturing uniquely
identifying data about the user device as well as the user’s
subscription to a cell provider, and forcibly redirecting the target
devices onto malicious networks where the attacker can intercept SMS
messages, calls, and internet traffic,</p>
<p>These FBS’s are sold from private corporations to law enforcement and
state surveillance agencies, though the increasing availability of
software defined radios (SDR) and relevant software has increasingly put
this technology in the hands of hacking organizations. The private
corporations that sell this hardware do so strictly to law enforcement
and intelligence agencies, never researchers, as such, there are very
few empirical, replicable studies of FBS technology. However, heuristics
are developed by known weaknesses in these protocols.</p>
<p>Also, the Electronic Frontier Foundation (EFF) maintains an open
database aggregating public records which show the various agencies and
law enforcement organizations that have acquired this technology. The
open database is called the Atlas of Surveillance.</p>
<ul class="incremental">
<li><a
href="https://atlasofsurveillance.org">https://atlasofsurveillance.org</a></li>
</ul>
<h2 id="enter-rayhunter">Enter: Rayhunter</h2>
<p>Rayhunter is an AGPL-3.0 licensed, free and open source software
project recently announced by the EFF. At the time of writing, the
Rayhunter software runs on the Orbic RC400L mobile hotspot. It
continuously reads the Qualcomm Mobile Diagnostic Logs (QMDL), sending
each log to a collection of analyzers, each targeting different
heuristics that may detect the presence of an FBS. We’ll take a look at
each of the analyzers in the following sections and toward the end we’ll
discuss how to set up this software on the Orbic device.</p>
<h2 id="analyzers">Analyzers</h2>
<p>The analyzers are capable of reading “information elements” from the
diagnostic logs and optionally triggering an “event” containing some
information about the event and a severity of “informational”, “low”,
“medium”, or “high”.</p>
<p>The recommended actions vary by level of severity as follows.</p>
<ul class="incremental">
<li><code>Informational</code>: No action necessary, can be hidden in
the user settings.</li>
<li><code>Low</code>: If combined with a large number of other warnings,
investigate.</li>
<li><code>Medium</code>: If combined with a few other warnings,
investigate.</li>
<li><code>High</code>: Always investigate.</li>
</ul>
<h3 id="connection-redirect-2g-downgrade">Connection Redirect 2G
Downgrade</h3>
<p>The “Connection Redirect 2G Downgrade Analyzer” checks for a redirect
from a rogue LTE (4G) network to a rogue 2G network, which generally
contains less security features than an LTE network, enabling further
exploitation.</p>
<p>This attack targets weaknesses in how cell towers engage in
load-balancing, that is, when traffic on a single cell tower is high but
on another it is low, the high traffic cell tower will redirect the user
to the low traffic tower as a means to balance the network traffic.
Since a tower only telling a user “find a new network” would require the
user to search through all the local towers, increasing network traffic
substantially, instead the towers are aware of each others’ capacities
and sends the user a specific tower to connect to instead. The user
device generally trust’s what the tower tells it.</p>
<p>Any 2G downgrade redirect triggers a high priority notification.</p>
<p>Source: <a
href="https://archive.conference.hitb.org/hitbsecconf2016ams/sessions/forcing-a-targeted-lte-cellphone-into-an-eavesdropping-network/">“Forcing
a targeted LTE cellphone into an eavesdropping network”: Lin
Huang</a></p>
<h3 id="priority-2g-downgrade-broadcast">Priority 2G Downgrade
Broadcast</h3>
<p>The “LTE SIB6 and SIB7 Downgrade Analyzer” checks for a 2G downgrade
request over a rogue LTE network with high priority. Functionally, the
attack is similar to the network redirect, but rather than reject from
the first FBS and redirect to the second, instead an FBS broadcasts a
“system information block” (SIB) with a high priority such that the user
device connects to its rogue 2G network.</p>
<p>Any 2G priority messages trigger a high priority notification.</p>
<p>Source: <a
href="https://api-depositonce.tu-berlin.de/server/api/core/bitstreams/99520397-8b47-4ea4-acd6-2b17c9a78bd4/content">“Why
We Cannot Win”: Shinjo Park (PDF)</a></p>
<h3 id="imsi-requested">IMSI Requested</h3>
<p>The “IMSI Requested Analyzer” checks for Non-Stratum Access (NAS)
messages over LTE which request the International Mobile Subscriber
Identity (IMSI) from the target device. In this scenario, the attacker
sends an IMSI request to the target device to gain a unique identifier
for the mobile subscription. However, requesting the IMSI is a common
operation in connecting to a new network, so if the number of packets
exchanged is below a given threshold, it may trigger a false
positive.</p>
<p>If the IMSI request happens in the first few packets of the analysis,
it is likely a false positive; at the time of writing, an IMSI request
within the first 150 packets will give a medium priority notification,
indicating this may be expected behavior, otherwise it will give a high
priority notification.</p>
<h3 id="imsi-provided">IMSI Provided</h3>
<p>The “IMSI Provided Analyzer” checks for IMSI identity responses to
the cell network. This is similar to the above “IMSI Requested
Analyzer”, but it checks explicitly if the user device returned the
IMSI.</p>
<p>All IMSI responses to the cell network trigger a high priority
notification.</p>
<h3 id="null-cipher">Null Cipher</h3>
<p>The “Null Cipher Analyzer” checks for connection reconfigurations or
security-mode commands from an LTE network to use the LTE “null cipher”,
that is an unencrypted option on LTE generally reserved for testing or
emergency calling purposes.</p>
<p>This takes advantage of the option to send LTE traffic unencrypted,
though its integrity is still verified. As such, SMS messages, calls,
and websites visited may be exposed through the Null Cipher.</p>
<p>At the time of writing, the Null Cipher Analyzer is disabled as it
gives false positives due to a bug in an upstream software
dependency.</p>
<h2 id="installation-and-usage">Installation and Usage</h2>
<h3 id="installation">Installation</h3>
<p>To use the Rayhunter software with an Orbic RC400L mobile hotspot,
we’ll use the following commands in a shell. Note that this assumes you
are using a Linux or MacOS operating system because Windows is an
affront to God.</p>
<p>We use <code>curl</code> to download the release bundle. At the time
of writing, <code>v0.2.7</code> is the latest version so this is the
version listed below. We use the <code>-LO</code> options where
<code>L</code> signals to handle any redirects to the actual file and
<code>O</code> signals to place the downloaded data into a file matching
that in the link. Note that our file will be
<code>./release.tar</code>.</p>
<div class="sourceCode" id="cb1"><pre
class="sourceCode bash"><code class="sourceCode bash"><span id="cb1-1"><a href="#cb1-1" aria-hidden="true" tabindex="-1"></a><span class="ex">curl</span> <span class="at">-LO</span> https://github.com/EFForg/rayhunter/releases/download/v0.2.7/release.tar</span></code></pre></div>
<p>We use the <code>curl</code> command again to download the SHA-256
hash of the downloaded file. This is a means to check the validity of
the download in case of any in-transit data corruption. The downloaded
hash will be written to <code>./release.tar.sha256</code>.</p>
<div class="sourceCode" id="cb2"><pre
class="sourceCode bash"><code class="sourceCode bash"><span id="cb2-1"><a href="#cb2-1" aria-hidden="true" tabindex="-1"></a><span class="ex">curl</span> <span class="at">-LO</span> https://github.com/EFForg/rayhunter/releases/download/v0.2.7/release.tar.sha256</span></code></pre></div>
<p>The contents of <code>./release.tar.sha256</code> should be similar
to the following. Note that if you are downloading a different release,
the file content may be different.</p>
<div class="sourceCode" id="cb3"><pre
class="sourceCode txt"><code class="sourceCode default"><span id="cb3-1"><a href="#cb3-1" aria-hidden="true" tabindex="-1"></a>5adbcf812175fec5995f190b9be2fa5283806435e36da089083402b932547599  release.tar</span></code></pre></div>
<p>We can verify the integrity using the <code>sha256sum</code> command.
This reads the <code>./release.tar.sha256</code> file and checks the
SHA-256 hash in it against its corresponding file. The following should
print “<code>release.tar: OK</code>” to the terminal. If not, start the
process over.</p>
<div class="sourceCode" id="cb4"><pre
class="sourceCode bash"><code class="sourceCode bash"><span id="cb4-1"><a href="#cb4-1" aria-hidden="true" tabindex="-1"></a><span class="fu">sha256sum</span> <span class="at">-c</span> release.tar.sha256</span></code></pre></div>
<p>Next we unpack the download with <code>tar</code> using the
<code>-xf</code> flag where the <code>x</code> signals to extract the
data while <code>f &lt;filename&gt;</code> indicates which to extract.
The following also removes the <code>.tar</code> archive and its SHA-256
hash if the extraction is successful.</p>
<div class="sourceCode" id="cb5"><pre
class="sourceCode bash"><code class="sourceCode bash"><span id="cb5-1"><a href="#cb5-1" aria-hidden="true" tabindex="-1"></a><span class="fu">tar</span> <span class="at">-xf</span> release.tar <span class="kw">&amp;&amp;</span> <span class="fu">rm</span> release.tar release.tar.sha256</span></code></pre></div>
<p>From here we turn on the Orbic device and plug it into the computer
with a USB-C cable.</p>
<p>Then we run the installation script.</p>
<div class="sourceCode" id="cb6"><pre
class="sourceCode bash"><code class="sourceCode bash"><span id="cb6-1"><a href="#cb6-1" aria-hidden="true" tabindex="-1"></a><span class="ex">./install.sh</span></span></code></pre></div>
<p>Once this is finished, the Rayhunter should be running on the Orbic
device and will automatically start when turned on!</p>
<p>Updating to a new release can be done by simply running the above
steps with the newest release version in the future.</p>
<h3 id="usage">Usage</h3>
<p>Since it runs automatically after installation, there is nothing more
to do to activate the device, however, it does put together a report on
a local website we can view from the browser. We can access the website
either by connecting a phone or computer to it over WiFi, or over a
USB-C cable, provided the Android Debug Bridge (<code>adb</code>) is
installed on the computer.</p>
<h4 id="on-wifi">On WiFi</h4>
<p>To use over WiFi, connect the phone or computer to the device and
visit the following in a web browser. Note that HTTPS is not enabled at
the time of writing, so the browser may give a warning of unencrypted
web traffic.</p>
<div class="sourceCode" id="cb7"><pre
class="sourceCode txt"><code class="sourceCode default"><span id="cb7-1"><a href="#cb7-1" aria-hidden="true" tabindex="-1"></a>http://192.168.1.1:8080</span></code></pre></div>
<h4 id="on-usb-c">On USB-C</h4>
<p>To use over USB-C, use the <code>adb</code> command to forward the
data to port 8080 on your device.</p>
<div class="sourceCode" id="cb8"><pre
class="sourceCode bash"><code class="sourceCode bash"><span id="cb8-1"><a href="#cb8-1" aria-hidden="true" tabindex="-1"></a><span class="ex">adb</span> forward tcp:8080 tcp8080</span></code></pre></div>
<p>Then visit <code>http://localhost:8080</code>.</p>
<h2 id="conclusion">Conclusion</h2>
<p>The Rayhunter is one of a few FBS detection solutions available. This
software in particular parses through Qualcomm Mobile Diagnostic Logs to
find activity that appears to be that of an FBS. It is important to note
that this is a proof of concept at the time of writing and should not be
used in high-risk situations. That said, there is very little empirical
data in the wild of FBS usage, as such the development of technologies
like Rayhunter depend on using known vulnerabilities in modern cell
networking protocols and using the data gathered to make adjustments in
the future. The Electronic Frontier Foundation has a Signal channel open
to send any captured data by these Rayhunter devices so that more large
scale analysis can be conducted.</p>
<p>Until next time, Peace.</p>
  <div class="debug-grid"></div>
  <script src="src/index.js"></script>
</body>
</html>
