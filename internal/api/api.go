package api

import (
	"github.com/go-chi/chi/v5"
)

type Api struct {
	Router *chi.Mux
}
