package sample1

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestCall(t *testing.T) {
	protocol := SampleProtocol(nil)
	getBazDesc := protocol.Methods["getBaz"]
	args := getBazDesc.MakeArg()
	_, err := getBazDesc.Handler(context.Background(), args)
	require.NoError(t, err)
}
