---
layout: note
title: OSI Model
draft: false
date: 2019-06-12 18:20:00 +0200
author: Victor Hachard
---

![seven-layers-OSI-model]({{site.baseurl}}/res/osi-model/seven-layers-OSI-model.png)

When most non-technical people hear the term “seven layers”, they either think of the popular Super Bowl bean dip or they mistakenly think about the seven layers of Hell, courtesy of Dante’s Inferno (there are nine). For IT professionals, the seven layers refer to the Open Systems Interconnection (OSI) model, a conceptual framework that describes the functions of a networking or telecommunication system.

The model uses layers to help give a visual description of what is going on with a particular networking system. This can help network managers narrow down problems (Is it a physical issue or something with the application?), as well as computer programmers (when developing an application, which other layers does it need to work with?). Tech vendors selling new products will often refer to the OSI model to help customers understand which layer their products work with or whether it works “across the stack”.

[ Related: What is IPv6, and why aren’t we there yet? ]
Conceived in the 1970s when computer networking was taking off, two separate models were merged in 1983 and published in 1984 to create the OSI model that most people are familiar with today. Most descriptions of the OSI model go from top to bottom, with the numbers going from Layer 7 down to Layer 1. The layers, and what they represent, are as follows:

## Layer 7 - Application

To further our bean dip analogy, the Application Layer is the one at the top - it’s what most users see. In the OSI model, this is the layer that is the “closest to the end user”. Applications that work at Layer 7 are the ones that users interact with directly. A web browser (Google Chrome, Firefox, Safari, etc.) or other app - Skype, Outlook, Office - are examples of Layer 7 applications.

## Layer 6 - Presentation

The Presentation Layer represents the area that is independent of data representation at the application layer - in general, it represents the preparation or translation of application format to network format, or from network formatting to application format. In other words, the layer “presents” data for the application or the network. A good example of this is encryption and decryption of data for secure transmission - this happens at Layer 6.

## Layer 5 - Session

When two devices, computers or servers need to “speak” with one another, a session needs to be created, and this is done at the Session Layer. Functions at this layer involve setup, coordination (how long should a system wait for a response, for example) and termination between the applications at each end of the session.

## Layer 4 – Transport

The Transport Layer deals with the coordination of the data transfer between end systems and hosts. How much data to send, at what rate, where it goes, etc. The best known example of the Transport Layer is the Transmission Control Protocol (TCP), which is built on top of the Internet Protocol (IP), commonly known as TCP/IP. TCP and UDP port numbers work at Layer 4, while IP addresses work at Layer 3, the Network Layer.

## Layer 3 - Network

Here at the Network Layer is where you’ll find most of the router functionality that most networking professionals care about and love. In its most basic sense, this layer is responsible for packet forwarding, including routing through different routers. You might know that your Boston computer wants to connect to a server in California, but there are millions of different paths to take. Routers at this layer help do this efficiently.

## Layer 2 – Data Link

The Data Link Layer provides node-to-node data transfer (between two directly connected nodes), and also handles error correction from the physical layer. Two sublayers exist here as well - the Media Access Control (MAC) layer and the Logical Link Control (LLC) layer. In the networking world, most switches operate at Layer 2.

## Layer 1 - Physical

At the bottom of our OSI bean dip we have the Physical Layer, which represents the electrical and physical representation of the system. This can include everything from the cable type, radio frequency link (as in an 802.11 wireless systems), as well as the layout of pins, voltages and other physical requirements. When a networking problem occurs, many networking pros go right to the physical layer to check that all of the cables are properly connected and that the power plug hasn’t been pulled from the router, switch or computer, for example.
