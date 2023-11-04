package server

import (
	"context"
	"fmt"
	"log"
	"net"
	"userservice/userpb"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type user struct {
	id      int64
	fname   string
	city    string
	phone   string
	height  float32
	married bool
}

var users = []user{
	{id: 1, fname: "Hetansh", city: "Pune", phone: "+918983457679", height: 5.8, married: true},
	{id: 2, fname: "Harvey", city: "Atlanta", phone: "+1999222333444", height: 5.9, married: true},
	{id: 3, fname: "Louise", city: "Middle Jutland", phone: "+4594358378", height: 5.6, married: true},
}

type server struct {
	userpb.UnimplementedUserServiceServer
}

func (s *server) GetSingleUsers(ctx context.Context, r *userpb.UserRequest) (*userpb.UserResponse, error) {
	id := r.GetId()
	res := &userpb.UserResponse{}
	for _, u := range users {
		if u.id == id {
			res = &userpb.UserResponse{Id: u.id, Fname: u.fname, City: u.city, Phone: u.phone, Height: u.height, Married: u.married}
			break
		}
	}
	if res.Id == 0 {
		return nil, status.Errorf(codes.NotFound, "user not found")
	}
	return res, nil
}

func (s *server) GetManyUsers(ctx context.Context, r *userpb.UserListRequest) (*userpb.UserListResponse, error) {
	ids := r.Ids
	result := &userpb.UserListResponse{}
	for _, u := range users {
		for _, i := range ids {
			if i == u.id {
				res := &userpb.UserResponse{Id: u.id, Fname: u.fname, City: u.city, Phone: u.phone, Height: u.height, Married: u.married}
				result.Users = append(result.Users, res)
				break
			}
		}
	}
	return result, nil
}

func StartServer() {
	lis, err := net.Listen("tcp", "0.0.0.0:50051")
	if err != nil {
		log.Fatalf("something happened at starting the server %v", err)
	}
	s := grpc.NewServer()
	userpb.RegisterUserServiceServer(s, &server{})

	fmt.Printf("server started at %v\n", lis.Addr())

	if err := s.Serve(lis); err != nil {
		log.Fatalf("Failed to server %v", err)
	}

}
