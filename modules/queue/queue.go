package queue

import (
	"encoding/json"

	"github.com/bgentry/que-go"
	"github.com/jackc/pgx"
	"github.com/pkg/errors"
)

const (
	ParseGeoRequestJob = "ParseGeoRequestJob"
)

type ParseGeoRequest struct {
	IP   string `json:"ip"`
	Slug string `json:"slug"`
}

func Dispatch(qc *que.Client, request ParseGeoRequest) error {
	enc, err := json.Marshal(request)
	if err != nil {
		return errors.Wrap(err, "Marshalling the IndexRequest")
	}

	j := que.Job{
		Type: ParseGeoRequestJob,
		Args: enc,
	}

	return errors.Wrap(qc.Enqueue(&j), "Enqueueing Job")
}

// GetPgxPool based on the provided database URL
func GetPgxPool(dbURL string) (*pgx.ConnPool, error) {
	pgxcfg, err := pgx.ParseURI(dbURL)
	if err != nil {
		return nil, err
	}

	pgxpool, err := pgx.NewConnPool(pgx.ConnPoolConfig{
		ConnConfig:   pgxcfg,
		AfterConnect: que.PrepareStatements,
	})

	if err != nil {
		return nil, err
	}

	return pgxpool, nil
}

// Setup a *pgx.ConnPool and *que.Client
// This is here so that setup routines can easily be shared between web and
// workers
func Setup(dbURL string) (*pgx.ConnPool, *que.Client, error) {
	pgxpool, err := GetPgxPool(dbURL)
	if err != nil {
		return nil, nil, err
	}

	qc := que.NewClient(pgxpool)

	return pgxpool, qc, err
}