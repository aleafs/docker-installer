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

func hostInterfaces() ([]*net.IPNet, error) {
	addresses, err := net.InterfaceAddrs()
	if err != nil {
		return nil, err
	}

	var output = make([]*net.IPNet, 0)
	for _, each := range addresses {
		if addr, ok := each.(*net.IPNet); ok {
			if addr.IP.IsPrivate() && addr.IP.To4() != nil {
				output = append(output, addr)
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

func dockerInformation() (*dockerInfo, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "docker",
		"system", "info", "--format", "{{json .}}")
	buffer, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var config dockerInfo
	if err = json.Unmarshal(buffer, &config); err != nil {
		return nil, err
	}

	return &config, nil
}

func main() {

	config, err := dockerInformation()
	if err != nil {
		log.Println(err)
	}

	if config == nil {
		config = &dockerInfo{
			NumCPU: runtime.NumCPU(),
		}
	}

	if len(config.DefaultAddressPools) < 1 {
		config.DefaultAddressPools = []addressPool{
			{
				Base: "172.16.0.0/12",
				Size: 24,
			},
		}
	}

	fmt.Println(config)

	addrs, err := hostInterfaces()
	if err != nil {
		log.Fatalln(err)
	}

	fmt.Println(addrs)

}
