package base

// Version is the build version, set at build time, using `go build -ldflags "-X github.com/GopeedLab/gopeed/pkg/base.Version=1.0.20260923"`.
var Version = "1.0.20260923"
var InDocker string

func init() {
	if Version == "" {
		Version = "dev"
	}
}
