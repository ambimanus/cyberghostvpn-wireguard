<p alighn="center">
 <a href="https://www.cyberghostvpn.com/"> <img src="https://raw.githubusercontent.com/ambimanus/cyberghostvpn-wireguard/main/.img/CyberGhost-Logo-Header.png"></a>
</p>

# CyberGhost VPN

This is a WireGuard client docker that uses the CyberGhost Cli. It allows routing containers traffic through WireGuard.

[Docker Image](https://hub.docker.com/r/ambimanus/cyberghostvpn-wireguard)

## What is WireGuard?

WireGuard® is an extremely simple yet fast and modern VPN that utilizes state-of-the-art cryptography. It aims to be faster, simpler, leaner, and more useful than IPsec, while avoiding the massive headache. It intends to be considerably more performant than OpenVPN. WireGuard is designed as a general-purpose VPN for running on embedded interfaces and super computers alike, fit for many different circumstances.

## How to use this image

Start the image using optional environment variables shown below. The end-user must supply a volume for local storage of the CyberGhost auth and token files. Supplied DNS is optional to avoid using ISP DNS during the initial connection.

```
docker run -d --cap-add=NET_ADMIN --dns 1.1.1.1 \
           -v /local/path/to/config:/home/root/.cyberghost:rw \
           -e ACC=example@gmail.com \
           -e PASS=mypassword \
           -e CG_FLAGS="--country-code US --torrent" \
           -e ALLOW_NETWORK=192.168.1.0/24 \
           -e ALLOW_PORTS=9090,8080 \
           cyberghostvpn-wireguard
```

Other containers can connect to this image by specifying the provided network in their `docker run` command, e.g. `--net=container:cyberghostvpn-wireguard`.

Environment variables:
- `ALLOW_NETWORK` - Adds a route from the container network to the specified network once the VPN is connected. CIDR notation [192.168.1.0/24]
- `ALLOW_PORTS` - Allow access to listed ports when VPN is connected. Delimited by comma [8080,8081,9000]
- `ACC` - CyberGhost username - Used for login
- `PASS` - CyberGhost password - Used for login
- `CG_FLAGS` - Passes options to the cyberghost client. Examples:
    - `CG_FLAGS='--country-code US --torrent'`
    - `CG_FLAGS='--country-code US --traffic'`
    - `CG_FLAGS='--country-code US --streaming 'Netflix US''`
   See [GyberGhost selecting a country or single server](https://support.cyberghostvpn.com/hc/en-us/articles/360020673194--How-to-select-a-country-or-single-server-with-CyberGhost-on-Linux) for more details.

Note: If the other containers have exposed ports for example a WEBUI. Forward that port in the cyberghostvpn-wireguard image, add the port to WHITELISTPORTS environment variable, and set your local LAN using NETWORK environment variable.

## Firewall

This image has a custom built-in firewall. On initial start, all traffic is blocked except CyberGhost API IP and Local DNS for resolve. After VPN is connected Local DNS is blocked on Port 53. For first time use the firewall will go through a setup phase to include whitelisted ports where the firewall will be inactive.

See the firewall section located in start.sh for details.

## Disclaimer

This project was developed independently for personal use. CyberGhost has no affiliation, nor has control over the content or availability of this project.
