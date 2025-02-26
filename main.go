package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"os/exec"
	"runtime"
	"time"
)

func hostInterfaceAddr() ([]net.IP, error) {
	addresses, err := net.InterfaceAddrs()
	if err != nil {
		return nil, err
	}

	var output = make([]net.IP, 0)
	for _, each := range addresses {
		if addr, ok := each.(*net.IPNet); ok {
			ipv4 := addr.IP.To4()
			if ipv4 != nil && ipv4.IsPrivate() {
				output = append(output, ipv4)
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
					if mask.Contains(ip) {
						// 地址可能冲突
						fmt.Println(mask.String() + ":" + ip.String())
					}
				}
			}
		}
	}

}
