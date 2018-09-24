package sample1

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestCall(t *testing.T) {
	c := SampleClient{}
	_, err := c.GetBaz(context.Background(), GetBazArg{})
	require.NoError(t, err)
}
