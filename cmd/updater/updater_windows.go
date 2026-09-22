//go:build windows

package main

import (
	"archive/zip"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func install(killSignalChan chan<- any, updateChannel, packagePath, destDir string) (bool, error) {
	switch updateChannel {
	case "windowsInstaller":
		return false, installByInstaller(killSignalChan, packagePath)
	default:
		return true, installByPortable(killSignalChan, packagePath, destDir)
	}
}

// installByInstaller runs the downloaded NSIS installer directly.
func installByInstaller(killSignalChan chan<- any, packagePath string) error {
	cmd := exec.Command(packagePath)
	if err := cmd.Start(); err != nil {
		return err
	}

	killSignalChan <- nil
	return nil
}

// installByPortable extracts the portable version to the destination directory
func installByPortable(killSignalChan chan<- any, packagePath, destDir string) error {
	killSignalChan <- nil

	reader, err := zip.OpenReader(packagePath)
	if err != nil {
		return err
	}
	defer reader.Close()

	for _, file := range reader.File {
		cleanName := filepath.Clean(file.Name)
		if strings.HasPrefix(cleanName, "..") || filepath.IsAbs(cleanName) {
			continue
		}
		path := filepath.Join(destDir, cleanName)

		if file.FileInfo().IsDir() {
			os.MkdirAll(path, file.Mode())
			continue
		}

		if err := os.MkdirAll(filepath.Dir(path), os.ModePerm); err != nil {
			return err
		}

		dstFile, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, file.Mode())
		if err != nil {
			return err
		}

		srcFile, err := file.Open()
		if err != nil {
			dstFile.Close()
			return err
		}

		_, err = io.Copy(dstFile, srcFile)
		srcFile.Close()
		dstFile.Close()
		if err != nil {
			return err
		}
	}
	return nil
}
