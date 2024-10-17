package token

import "time"

type Maker interface {
	//CreateToken creates a new token for username and duration
	CreateToken(username string, duration time.Duration) (string, error) 

	//VerifyToken checkes if the token is valid or not4
	VerifyToken(token string) (*Payload, error)
}