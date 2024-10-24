// Code generated by sqlc. DO NOT EDIT.
// versions:
//   sqlc v1.26.0
// source: products.sql

package pgstore

import (
	"context"
	"time"

	"github.com/google/uuid"
)

const createProduct = `-- name: CreateProduct :one
INSERT INTO products (
    seller_id, product_name, description,
    baseprice, auction_end
) VALUES ($1, $2, $3, $4, $5)
RETURNING id
`

type CreateProductParams struct {
	SellerID    uuid.UUID `json:"seller_id"`
	ProductName string    `json:"product_name"`
	Description string    `json:"description"`
	Baseprice   float64   `json:"baseprice"`
	AuctionEnd  time.Time `json:"auction_end"`
}

func (q *Queries) CreateProduct(ctx context.Context, arg CreateProductParams) (uuid.UUID, error) {
	row := q.db.QueryRow(ctx, createProduct,
		arg.SellerID,
		arg.ProductName,
		arg.Description,
		arg.Baseprice,
		arg.AuctionEnd,
	)
	var id uuid.UUID
	err := row.Scan(&id)
	return id, err
}