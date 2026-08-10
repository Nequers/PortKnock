# PortKnock

A lightweight Windows GUI client for sending configurable TCP/UDP
port-knocking sequences.

PortKnock allows you to save multiple server profiles and quickly
send a configured sequence of TCP or UDP packets.

## Features

- TCP and UDP port knocking
- Up to 4 knock steps per profile
- Configurable destination IP address
- Configurable ports
- Configurable UDP payload
- Multiple saved profiles
- Save, load and delete profiles
- Configuration stored locally in `config.ini`
- No external `TCP.exe` required

## Example

Example TCP sequence:
12345 -> 34566 -> 345 -> 47800
