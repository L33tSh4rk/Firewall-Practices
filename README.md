# Firewall Practices

Hands-on firewall scenarios I solved while studying network security. Each scenario describes a network topology plus a set of requirements, and includes my solution as a ready-to-run script.

> Scenario statements are available in English and Portuguese (the original language, as they come from university coursework); scripts and comments are in English.

## Scenarios

| #  | Scenario | Tool | Concepts |
|----|----------|------|----------|
| 01 | [DMZ + screened LAN](iptables/01-dmz-screened-lan/) | iptables | default policies, NAT (MASQUERADE / DNAT), DMZ, screened LAN, MAC filtering, stateful rules |

## Repository layout

```
<tool>/
└── NN-scenario-name/
    ├── README.md        # scenario statement: topology + requirements
    ├── img/             # topology diagrams
    └── solution/
        └── firewall.sh  # rules that satisfy the requirements
```

## Running a solution

The scenarios were built and tested with [FirewallTester](https://github.com/luizabasseto/firewallTester/), a tool developed for the firewall classes at UTFPR. It spins up the hosts and services of each topology and checks whether the rules meet the requirements.

To apply a solution on the firewall host of a lab:

```bash
sudo bash iptables/01-dmz-screened-lan/solution/firewall.sh
```

> **Warning:** these scripts flush existing rules and set restrictive default policies (e.g. `INPUT`/`OUTPUT` to `DROP`). Run them only inside a lab environment, never on your own machine or on a remote host you reach via SSH.

## Credits

- Scenario statements come from the firewall coursework at UTFPR.
- [FirewallTester](https://github.com/luizabasseto/firewallTester/), used to build and test the scenarios.
