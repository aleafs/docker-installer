package main

import (
	"context"
	"encoding/json"
	"github.com/fatih/color"
	"log"
	"net"
	"os"
	"os/exec"
	"runtime"
	"syscall"
	"time"
)

type interfaceAddr struct {
	Name string
	Addr net.IP
}

func hostInterfaceAddr() ([]interfaceAddr, error) {
	interfaces, err := net.Interfaces()
	if err != nil {
		return nil, err
	}

	var output = make([]interfaceAddr, 0)
	for _, each := range interfaces {
		address, _ := each.Addrs()
		if len(address) < 1 {
			continue
		}

		for _, addr := range address {
			if ipNet, ok := addr.(*net.IPNet); ok {
				if ipNet.IP.IsPrivate() && ipNet.IP.To4() != nil {
					output = append(output, interfaceAddr{
						Name: each.Name,
						Addr: ipNet.IP,
					})
				}
			}
		}
	}

	return output, nil
}

type addressPool struct {
	Base string `json:"Base"`
	Size int    `json:"Size"`
}
type dockerInfo struct {
	ServerVersion       string        `json:"ServerVersion"`
	NumCPU              int           `json:"NCPU"`
	MemTotal            int64         `json:"MemTotal"`
	DockerRootDir       string        `json:"DockerRootDir"`
	DefaultAddressPools []addressPool `json:"DefaultAddressPools"`
}

func dockerInformation() (dockerInfo, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var config dockerInfo
	buffer, err := exec.CommandContext(ctx, "docker",
		"system", "info", "--format", "{{json .}}").Output()
	if err != nil {
		return config, err
	}

	err = json.Unmarshal(buffer, &config)
	return config, err
}

func validateConfig(config dockerInfo) dockerInfo {
	if config.NumCPU < 1 {
		config.NumCPU = runtime.NumCPU()
	}

	if len(config.DefaultAddressPools) < 1 {
		config.DefaultAddressPools = []addressPool{
			{
				Base: "172.16.0.0/12",
				Size: 24,
			},
		}
	}

	return config
}

func main() {

	config, err := dockerInformation()
	if err != nil {
		log.Println(err)
	}

	config = validateConfig(config)
	ipaddr, err := hostInterfaceAddr()
	if len(ipaddr) > 0 {
		for _, each := range config.DefaultAddressPools {
			_, mask, _ := net.ParseCIDR(each.Base)
			if mask != nil {
				for _, ip := range ipaddr {
					if mask.Contains(ip.Addr) {
						color.Red("%s (%s) conflicts %s\n", ip.Addr, ip.Name, mask.String())
					}
				}
			}
		}
	}
}

func search() string {
	for _, each := range []string{
		"/etc/docker/daemon.json",
	} {
		return each
	}

	return "/etc/docker/daemon.json"
}

// @see: https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file
func aaa() {
	os.Stat("/etc/docker/daemon.json")
	exec.Command("dockerd", "--validate", "--config-file").CombinedOutput()
}

// data-root
func diskUsage(prefix string) (uint64, uint64, error) {
	var (
		stat syscall.Statfs_t
		err  = syscall.Statfs(prefix, &stat)
	)

	if err != nil {
		return 0, 0, err
	}

	return stat.Blocks * uint64(stat.Bsize), stat.Bfree * uint64(stat.Bsize), nil
}
