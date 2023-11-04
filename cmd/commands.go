package cmd

import (
	"context"
	"fmt"
	"log"
	"strconv"
	"strings"
	"userservice/server"
	"userservice/userpb"

	"github.com/spf13/cobra"
	"google.golang.org/grpc"
	"google.golang.org/grpc/status"
)

var fetchsingleCmd = &cobra.Command{
	Use:   "fetchsingle",
	Short: "fetch the single user provided id",
	//adds cobra command function
	Run: func(cmd *cobra.Command, args []string) {
		conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
		if err != nil {
			log.Fatal("dail up in client failed", err)
		}
		defer conn.Close()

		c := userpb.NewUserServiceClient(conn)

		var id int
		for _, i := range args {
			// only need single flag
			// break the loop after first param
			id, err = strconv.Atoi(strings.TrimSpace(i))
			if err != nil {
				log.Fatal("failed to parse input")
			}
			break
		}

		res, err := c.GetSingleUsers(context.Background(), &userpb.UserRequest{Id: int64(id)})
		if err != nil {
			respErr, ok := status.FromError(err)
			if ok {
				log.Println(respErr.Code())
				log.Println(respErr.Message())
			} else {
				log.Fatalf("major error: %v", err)
			}
		}
		fmt.Println(res)
	},
}

var fetchmultiCmd = &cobra.Command{
	Use:   "fetchmulti",
	Short: "fetch the multiple users provided space seperated id",
	//adds cobra command function
	Run: func(cmd *cobra.Command, args []string) {
		params := make([]int64, 0)
		for _, i := range args {
			j, err := strconv.Atoi(i)
			if err != nil {
				log.Fatal("failed to parse input")
			}
			params = append(params, int64(j))
		}

		conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
		if err != nil {
			log.Fatal("dail up in client failed", err)
		}
		defer conn.Close()

		c := userpb.NewUserServiceClient(conn)
		res, err := c.GetManyUsers(context.Background(), &userpb.UserListRequest{Ids: params})

		if err != nil {
			respErr, ok := status.FromError(err)
			if ok {
				log.Println(respErr.Code())
				log.Println(respErr.Message())
			} else {
				log.Fatalf("major error: %v", err)
			}
		}
		for _, j := range res.Users {
			fmt.Println(j)
		}
	},
}

var startserver = &cobra.Command{
	Use:   "startserver",
	Short: "startserver at specified client",
	//adds cobra command function
	Run: func(cmd *cobra.Command, args []string) {
		server.StartServer()
	},
}

func init() {
	RootCmd.AddCommand(
		fetchsingleCmd,
		fetchmultiCmd,
		startserver,
	)
}
