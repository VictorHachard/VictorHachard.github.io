---
layout: note
draft: false
date: 2020-10-09 10:1:00 +0200
author: Victor Hachard
categories: ['System Administration']
---

About the quite popular DS4243 (and other NetApp stuff)
Hello fellow DataHoarders,

long-time lurker, part-time hoarder and full-time employee in the storage industry here.

I noticed that recently, there are a lot of threads coming up here about the NetApp disk shelves (DS4243 and variants), and since I've been working with these systems in my daily job at a value-added reseller for about 10 years now, I thought I'd chime in here with a few insights of my own.

First, what is a DS4243?

I know most of you are probably aware of this already, but just for completeness: The DS4243 is a disk shelf that has 24 slots for 3.5'' harddisks. It includes a SAS->SATA expander in the IO module so that you can access all these disks through a single 4-lane SAS port on the back of the module. All disks are hot-swappable, and there is no technical limitation on which disks you can insert (i.e. you don't need specially-keyed disks, or disks with a custom firmware).

There are actually many different shelves with a similar name, for example DS4246 (which has a 6GBit SAS module called IOM6 instead of the 3GBit IOM3), DS2246 (which is the 2U version with 24 2.5'' slots for SAS or SSD disks) and the DS4486 (which uses "double-deep" disk carriers and squeezes 48 3.5'' disks in 4U). Most of these are more expensive or rare or not really useful for the general DataHoarder though...

The reason those shelves are so popular is that you can get them very cheaply on eBay or from leasing remarketing firms etc. For example, in Germany there is "Miller Anlagen", a leasing company that sells a DS4243 shelf with 24x3TB disks in it for a bit over 2k € list price, which translates to about 100€ per drive. Yes, it's more than when you buy them on the cheap somewhere, but you also get the shelf and the IO modules, and often some limited warranty or support (and, if you can negotiate well, they might even drop the price a bit). Also, if you have connections to some VARs or resellers, you might want to talk to them because they might have some of these shelves as "trade-in" from customer projects that they probably throw out (don't ask how many shelves full of, say, 1TB disks we throw out each year...)

Some Notes about the shelves:

Even though you can mix drives and drive types in the same shelf (i.e. SAS and SATA disks), you shouldn't. The problem is that the non-equal RPMs of the drives can cause the shelf to vibrate and oscillate, reducing the lifespan of all disks in it. You can, however, freely mix in non-rotating disks i.e. SSDs

Make sure that the shelf you're getting has all bays populated by carriers. They are quite tricky to find on their own. And the blinds for the empty bays don't help when you want to swap in a drive

Some carriers (especially older models) don't work with newer drives. They have some small glue logic for hot-swapping and multi-path access, and I found that older carriers don't like e.g. newer 4tb disks

The connectors on the I/O modules are SFF 8436 (regular QSFP/QSFP+, not the miniSAS or similar) so if you're buying cables, keep that in mind

They have up to 4 power supplies, however, they will still work with even only 1 PSU running

You can daisy-chain up to 10 of them, the rule for the connection is to connect from the connector with the round symbol in the first shelf to the connector with the square symbol of the second shelf, and so on. Another rule is to connect the A module (the top one) only to the other A-modules, and to connect the B-module (the lower one) only to other B-modules.

Note that you might have only one IOM module per shelf, depending on how your shelf has been used. This is fine.

Make sure that each shelf gets a unique ID. You can change the ID with a little button on the front, right below the ID display, behind the plastic bezel. Push long until the first digit starts flashing, then push a few times until you have the number you want, then press long again, do the same for the second digit, then press long again to finish. You need to power-cycle the shelf for the new ID to take effect.

What else could you do with NetApp hardware

I have recently noticed that NetApp hardware can be very cheap, especially if you're looking for some older models. Actually using a NetApp system for storing your data might be a nice option because you get a lot of data security right out of the box, without having to research much into filesystems, mainboards, servers, SAS adapters, etc.

The upsides of using NetApp systems are:

rock-solid RAID and filesystem implementation. In my 10 years in the job I have never seen any NetApp system lose data from any failed hardware component. Sure, drives fail, CPUs fail, systems crash and halt and stop booting until you replace some failed part, but the data on the disks is always in a good state. I might write up more on this in a later post if there's interest, but the file system (called WAFL) is probably one of the best in the industry

solid CIFS and NFS server implementations. No need to fiddle with samba config files ;-)

If you need it you can have active-active clustering built-in

You might get them easily from VARs because they sometimes throw them out as well.

Often, systems with fewer software licenses cost even less. Ask them for a system without any licenses, maybe they'll drop the price even further. If you need license keys later they are quite easy to obtain (ping me).

Automatic deduplication and compression (both optional) of the data you store, to reduce the required storage even more. Of course this doesn't help for audio/video data, but it does help a lot for (uncompressed) software or even ISOs.

Snapshots! Like btrfs/zfs snapshots. Integrated, scheduled, performance-neutral, and on 4k block level.

Data transfer/mirroring integrated, so you can transfer whole volumes between multiple NetApp systems with minimal overhead (think btrfs-send / btrfs-receive), to mirror your hoard to a friend at the other side of the country, for example ;-) This works a lot faster than robocopy/rsync as it runs on the block level and doesn't have to traverse directories/metadata

I might write more about some of the unique features of NetApp systems later, if there's interest.

Of course there are also downsides:

being enterprise systems, they are not built for desktop usage. That means they are loud. And they can draw a lot of power, but then again we're talking about people who have 1 or 2 DS4243 shelves in their basement already so neither of these two points will make a difference to them :)

My own measurements show that, for example, a FAS2500 populated with 12 internal SATA disks and 2 controllers will draw about 230W in idle, which is not that much more than what a reasonable NAS server would draw I guess

Not much customization. It is a closed system after all. Earlier versions (before OS version 8.0) were a completely self-contained operating system based on BSD, newer versions run as kernel modules and userspace helpers on top of FreeBSD. While there is access to the FreeBSD shell on those (even as root), I don't know how feasible it would be to, say, install your favorite Home TV streaming server on there. So you might need a separate server after all...

Proprietary file system with no free tool to read it at all. This might be a showstopper for some (I have reverse-engineered some early metadata for the filesystem but I'm reluctant to share it since part of it has been obtained through disassembling)

So, what would you need to look out for when deciding to use NetApp hardware for your data-hoarding?

Well, first you have to decide on how much data you need to access. NetApp systems have a hardcoded limit on how many disk drives they can handle. The smaller systems handle only maybe 68 disks, larger controllers can handle up to 1400 or so.

Also, be aware that while you can use arbitrary (non-branded) harddisks with the system, you should stick to sizes that are supported, or you may find that the system doesn't, for example, know about your 10TB harddisk and clips it to 8TB.

Then you'd have to check that the hardware you use can actually interface to the DS4243 shelves. Some older NetApp controllers didn't have SAS integrated and for them you'd need a SAS adapter card. While this is an industry-standard model, I wouldn't count on any model to work in a NetApp controller, so you'd better get an officially supported one, just to be sure.

The actual speed or model of the controller doesn't really factor in that much. I mean this is not so much about low-latency performance and hundreds of megabytes per second transfer here... It's more about data protection. For example, I have a very old NetApp FAS270 model (which was introduced around 2005 or so) which still runs perfectly fine with 14x600GB FC drives. It has a 2-core MIPS 650MHz CPU on it and I can still get it to saturate a 1GBit link with CIFS transfers. So if you're fine with that, almost any NetApp controller will do for you ;-)

Generally, NetApp controllers come in 2 variants: Standalone and embedded. Stand-alone are like a server, i.e. it's a separate chassis which has PCI slots, much like a traditional server. Embedded controllers are smaller and get inserted directly into the first disk shelf instead of the IOM3 module. They are not expandable with PCI cards.

Speaking of expansion, you cannot add RAM or CPUs to a NetApp controller. The system checks this on boot and refuses to start if it detects a mismatch.

Here is a small overview over a few NetApp models.

Model	Type	Size	Max. # disks	# SAS ports	notes
FAS270	embedded (DS14)	3U	56	n/a	Very old controller. Uses DS14-type shelves (FC). No SAS connectivity
FAS2040	embedded (special)	2U	136	1	controller requires a special shelf. Cannot be inserted into DS4243
FAS2050	embedded (special)	4U	104	n/a	requires special shelf, cannot be inserted into DS4243. Can use PCI card for SAS connectivity.
FAS2220	embedded	2U	60 (12 disks internal + 2 shelves)	2	1 proprietary I/O slot for 10GbE
FAS2240-4	embedded	4U	144 (24 disks internal + 5 shelves)	2	1 proprietary I/O slot for 10GbE
FAS2520	embedded	2U	84 (3 shelves + 12 internal)	2	special 12-disk shelf for the controller
FAS2554	embedded	4U	144 (24 disks internal + 5 shelves)	2
FAS3070	standalone	3U	504 (21 shelves)	n/a	FAS 30xx is only supported up to OS version 7.x (e.g. no compression, no SMB3, ...)
FAS3220	standalone	3U	480 (20 shelves)	2
FAS3240	standalone	3U	600 (25 shelves)	2
The SAS card you need to look out for (if you have, e.g., a FAS3070) is the X2065A or in case you have a FAS2050, the X2062A.

You can check the hardware specs on https://hwu.netapp.com. It requires an account, but you can register one for free ("guest account") on https://support.netapp.com (click on "register now" on the right) which should be enough to give you access to the hardware universe. Yes, their homepage looks like it's from the 90's, and it probably is, but it works :)

Anyway, that's it for today. If you have questions, don't hesitate to ask. I might do some follow-up posts about data protection in general (why RAID is not enough, what a torn write is, and stuff like that) and/or particular NetApp features if there's enough interest.

Happy hoarding!

-Darkstar
