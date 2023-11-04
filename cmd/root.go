package cmd

import "github.com/spf13/cobra"

var RootCmd = &cobra.Command{
	Use:   "client",
	Short: "grpc client for fetching user information",
}
